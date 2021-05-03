---------------------------------------------------------------
-- Vending machine

--	Universidade Federal de Santa Catarina - UFSC
--	Alunos: 
		-- Fernando Henrique Lonzetti
		-- Felipe De Souza Tortato

---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all; -- Biblioteca adicionada para realizar operacoes com sinais signeds e unsigneds
use ieee.numeric_std.all;
use work.all;

-- Fizemos a maquina um pouco diferente do diagrama apresentado no projeto, de modo que ela seja expansivel para um maior numero de produtos (N produtos).
	
entity vending is -- Declaracao da entidade
	port(
		clk: in std_logic; -- Clock do circuito
		reset, bot_sel, bot_mais, bot_menos, bot_inicio, bot_prog: in std_logic; -- Botoes externos para o usuario interagir com a maquina
		evt_moeda: in std_logic; -- Evento de entrada de moeda e identificacao pelo detector
		valor_moeda, valor_produto: in std_logic_vector(7 downto 0); -- Entrada de valor da moeda detetada e entrada de programacao do custo de um novo produto
		lib_prod, lib_troco, lib_passagem_moeda: out std_logic := '0'; -- Sinais de controle da maquina para liberacao de produto, de troco e uma trava para evitar que moedas
		-- inseridas durante alguma operacao fiquem presas na maquina
		display_prod: out std_logic_vector(5 downto 0) := (others=>'0'); -- A maquina e expansivel para ate 64 produtos. Essa saida mostra o produto no display
		display_valor: out std_logic_vector(7 downto 0) := (others=>'0'); -- O valor do produto pode ser de ate 2,55 reais (0 ate 255 centavos). Essa saida mostra o preco do produto no display
		display_troco: out std_logic_vector(7 downto 0) := (others=>'0') -- Essa saida envia o valor da moeda para o liberador de troco (um equipamento parecido com o identificador de moedas, 
		-- mas que verifica o número de moedas a serem liberadas e devolve para o cliente). O troco pode ser de ate 2,55 reais (0 ate 255 centavos)
	);
end vending;

architecture arch of vending is
	type states is (inicial, vendas, programacao, prog_incrementa_sel_produto, prog_decrementa_sel_produto, prog_altera_valor_produto, vendas_soma_valor_moeda, vendas_selecao_produto, vendas_incrementa_sel_produto, vendas_decrementa_sel_produto, verifica_dinheiro_total, liberar_troco, liberar_produto); 
	-- Estados: consultar o diagrama de estados entregue junto ao projeto
	type array_produtos is array(0 to 63) of std_logic_vector(7 downto 0); -- Array de produtos: 64 posicoes com 8 bits para representacao do valor
	signal valor_por_produto: array_produtos := ((others=> (others=>'0'))); -- Sinal do tipo array_produtos
	signal state_act, state_nxt: states := inicial; -- Variaveis para armazenar o estado atual e proximo estagio para a FSM - Inicializacao no estado inicial
	signal tem_dinheiro, tem_troco: std_logic := '0'; -- Variaveis para armazenar flags de comparacao do dinheiro inserido e o valor do produto
	signal valor_inserido, valor_troco, soma_buff_valor: std_logic_vector(7 downto 0) := (others=>'0'); -- Variaveis para armazenar o valor inserido pelo usuario e o valor do troco
	signal produto, acum_buff_produto: unsigned(5 downto 0) := (others=>'0'); -- Variavel que armazena o produto atual que o usuario está alterando ou selecionando
	signal trava: std_logic := '0'; -- Trava do botao para nao executar multiplas vezes a acao do clique
begin

	process(clk, reset) -- Processo para configuracao dos registradores. O estado atual recebera o valor do proximo estado na proxima borda de subida de clock. Se o botao reset for
	-- acionado, o estado atual recebera o primeiro estado do sistema ("inicial") 
	begin
		if(reset = '1') then
			state_act <= inicial;
		elsif(clk'event AND clk = '0') then
			state_act <= state_nxt;
		end if;
	end process;
	
	-- FSM
	process(clk, reset) -- Definicoes da logica de proximo estado
	begin
		case state_act is
			-- Estado "inicial" e o estado de ligar o equipamento, se o equipamento for ligado com o botao de programacao ligado, vai para o estado "programacao", caso contrario
			-- vai para o estado "vendas"
			when inicial => 
				trava <= '0';
				if(bot_prog = '1') then 
					state_nxt <= programacao; 
					trava <= '1';
				elsif (bot_inicio = '0' AND bot_prog = '0') then
					state_nxt <= vendas;
				else 
					state_nxt <= inicial;
				end if;
				
			-- Modo programacao: selecao do produto a ser editado
			when programacao => 
				if(bot_inicio = '1' AND trava = '0') then 
					state_nxt <= inicial; 
				elsif(bot_mais = '1' AND trava = '0') then -- Botao "+" da maquina, para mudar (para mais) o produto que vai ser editado
					state_nxt <= prog_incrementa_sel_produto;
					trava <= '1';
				elsif(bot_menos = '1' AND trava = '0') then -- Botao "-" da maquina, para mudar (para menos) o produto que vai ser editado
					state_nxt <= prog_decrementa_sel_produto; 
					trava <= '1';
				elsif(bot_sel = '1' AND trava = '0') then -- Botao de selecao, para mudar o valor do produto selecionado
					state_nxt <= prog_altera_valor_produto;
					trava <= '1';
				else
					state_nxt <= programacao;
					if ((bot_inicio = '1' OR bot_mais = '1' OR bot_menos = '1' OR bot_sel = '1') AND trava = '1') then -- Condicao para evitar o uso indevido dos botoes
						trava <= '1';
					else
						trava <= '0';
					end if;
				end if;
			
			-- Modo incremento do seletor: incrementa a variavel que armazena o produto mostrado no LCD
			when prog_incrementa_sel_produto => 
				state_nxt <= programacao;
				
			-- Modo decremento do seletor: decrementa a variavel que armazena o produto mostrado no LCD
			when prog_decrementa_sel_produto => 
				state_nxt <= programacao;
			
			-- Modo produto selecionado: vai para um estado no e mudado o valor do produto selecionado		
			when prog_altera_valor_produto =>
				state_nxt <= programacao;
		
		
			-- Modo vendas: insercao de moedas
			when vendas =>
				if(bot_inicio = '1' AND trava = '0') then 
					state_nxt <= inicial;
				elsif(evt_moeda = '1' AND trava = '0') then 
					state_nxt <= vendas_soma_valor_moeda; 
					trava <= '1';
				elsif(bot_sel = '1' AND trava = '0') then
					state_nxt <= vendas_selecao_produto;
					trava <= '1';
				else
					state_nxt <= vendas;
					if ((bot_inicio = '1' OR evt_moeda = '1' OR bot_sel = '1') AND trava = '1') then -- Condicao para evitar o uso indevido dos botoes
						trava <= '1';
					else
						trava <= '0';
					end if;
				end if;
			
			-- Modo ler barramento: le o valor da moeda inserida para incrementar o contator do custo
			when vendas_soma_valor_moeda =>
				state_nxt <= vendas;
			
			-- Modo selecao de produto: apos inserir as moedas, o usuario pode selecionar o produto que ele deseja
			when vendas_selecao_produto =>
				if(bot_inicio = '1' AND trava='0') then 
					state_nxt <= vendas; 
					trava <= '1';				
				elsif(bot_mais = '1' AND trava = '0') then -- Botao "+" da maquina, para mudar (para mais) o produto que vai ser escolhido
					state_nxt <= vendas_incrementa_sel_produto;
					trava <= '1';
				elsif(bot_menos = '1' AND trava = '0') then -- Botao "-" da maquina, para mudar (para menos) o produto que vai ser escolhido
					state_nxt <= vendas_decrementa_sel_produto; 
					trava <= '1';
				elsif(bot_sel = '1' AND trava = '0') then
					state_nxt <= verifica_dinheiro_total;
					trava <= '1';
				else
					state_nxt <= vendas_selecao_produto;
					if ((bot_inicio = '1' OR bot_mais = '1' OR bot_menos = '1' OR bot_sel = '1') AND trava = '1') then -- Condicao para evitar o uso indevido dos botoes
						trava <= '1';
					else
						trava <= '0';
					end if;		
				end if;
			
			-- Modo incremento do seletor: incrementa a variavel que armazena o produto mostrado no LCD
			when vendas_incrementa_sel_produto =>
				state_nxt <= vendas_selecao_produto;
			
			-- Modo decremento do seletor: decrementa a variavel que armazena o produto mostrado no LCD			
			when vendas_decrementa_sel_produto =>
				state_nxt <= vendas_selecao_produto;
			
			-- Modo verificacao do dinheiro: verifica se a soma do valor e suficiente para comprar o produto e calcula o troco
			when verifica_dinheiro_total =>
				if(tem_dinheiro = '1' AND tem_troco = '1') then 
					state_nxt <= liberar_troco; 
				elsif(tem_dinheiro = '1' AND tem_troco = '0') then
					state_nxt <= liberar_produto;
				else
					state_nxt <= vendas_selecao_produto;
				end if;
				
			-- Modo liberacao de troco: conta se ha troco e escreve o valor do troco no registrador de saada
			when liberar_troco =>
				state_nxt <= liberar_produto;
				
			-- Modo liberacao de produto: libera o produto para o cliente	
			when liberar_produto =>
				state_nxt <= inicial;
		end case;
	end process;
	
	-- Logica de saida
	process(clk, reset) -- Definicões da logica de proximo estado
	begin
		case state_act is
			-- Estado inicial e o estado de ligar o equipamento, se o equipamento for ligado com o botao de programacao ligado, vai para o estado "programacao", caso contrario
			-- vai para o estado "vendas"
			when inicial => 
				lib_passagem_moeda <= '1';
				lib_troco <= '0';
				lib_prod <= '0';
				produto <= (others => '0');
				display_prod <= (others => '0');
				display_valor <= (others => '0');
				display_troco <= (others => '0');
				
			-- Modo programacao: selecao do produto a ser editado
			when programacao =>
				display_prod <= std_logic_vector(produto(5 downto 0));
				display_valor <= valor_por_produto(to_integer(produto));
				display_troco <= (others => '0');

			-- Modo incremento do seletor: incrementa a variavel que armazena o produto mostrado no LCD
			when prog_incrementa_sel_produto => 
				if(produto = "111111") then -- Volta ao produto "1" caso seja apertado o botao "mais" no produto "64"
					produto <= (others => '0');
				else
					acum_buff_produto <= produto + 1;
					produto <= acum_buff_produto;			
				end if;

			-- Modo decremento do seletor: decrementa a variavel que armazena o produto mostrado no LCD
			when prog_decrementa_sel_produto => 
				if(produto = "000000") then -- Volta ao produto "64" caso seja apertado o botao "menos" no produto "1"
					produto <= (others => '1');
				else
					acum_buff_produto <= produto - 1;			
					produto <= acum_buff_produto;
				end if;
			-- Modo produto selecionado: vai para um estado no qual e mudado o valor do produto selecionado		
			when prog_altera_valor_produto =>
				valor_por_produto(to_integer(produto)) <= valor_produto;
				
			-- Modo vendas: insercao de moedas
			when vendas =>
				lib_passagem_moeda <= '0';
				produto <= (others => '0');
				display_valor <= valor_inserido;
				display_prod <= (others => '0');
				display_troco <= (others => '0');

			-- Modo ler barramento: le o valor da moeda inserida para incrementar o contator do custo
			when vendas_soma_valor_moeda =>
				soma_buff_valor <= valor_inserido + valor_moeda;
				valor_inserido <= soma_buff_valor;
			-- Modo selecao de produto: apos inserir as moedas, o usuario pode selecionar o produto que ele deseja
			when vendas_selecao_produto =>
				display_prod <= std_logic_vector(produto(5 downto 0));
				display_valor <= valor_por_produto(to_integer(produto));
				lib_passagem_moeda <= '1';
				
				if(valor_inserido > valor_por_produto(to_integer(produto))) then
					tem_troco <= '1';
					tem_dinheiro <= '1';
				elsif(valor_inserido = valor_por_produto(to_integer(produto))) then
					tem_troco <= '0';
					tem_dinheiro <= '1';
				else
					tem_troco <= '0';
					tem_dinheiro <= '0';
				end if;

			
			-- Modo incremento do seletor: incrementa a variavel que armazena o produto mostrado no LCD
			when vendas_incrementa_sel_produto =>
				if(produto = "111111") then -- Volta ao produto "1" caso seja apertado o botao "mais" no produto "64"
					produto <= (others => '0');
				else
					acum_buff_produto <= produto + 1;
					produto <= acum_buff_produto;			
				end if;
			-- Modo decremento do seletor: decrementa a variavel que armazena o produto mostrado no LCD			
			when vendas_decrementa_sel_produto =>
				if(produto = "000000") then -- Volta ao produto "64" caso seja apertado o botao "menos" no produto "1"
					produto <= (others => '1');
				else
					acum_buff_produto <= produto - 1;
					produto <= acum_buff_produto;			
				end if;				
			-- Modo verificacao do dinheiro: verifica se a soma do valor e suficiente para comprar o produto e calcula o troco
			when verifica_dinheiro_total =>
				if(valor_inserido > valor_por_produto(to_integer(produto))) then
					valor_troco <= (valor_inserido - valor_por_produto(to_integer(produto)));
				end if;

			-- Modo liberacao de troco: conta se ha troco e escreve o valor do troco no registrador de saida
			when liberar_troco =>
				display_troco <= valor_troco;
				lib_troco <= '1';
				tem_troco <= '0';
				tem_dinheiro <= '0';
			-- Modo liberacao de produto: libera o produto para o cliente	
			when liberar_produto =>
				lib_prod <= '1';
				valor_inserido <= (others => '0');
				valor_troco <= (others => '0');
				
		end case;
	end process;
	
end arch;
