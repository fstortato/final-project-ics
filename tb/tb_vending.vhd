---------------------------------------------------------------
-- Test Bench for vending machine

--	Universidade Federal de Santa Catarina - UFSC
--	Alunos: 
		-- Fernando Henrique Lonzetti
		-- Felipe De Souza Tortato

---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use work.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all; -- Biblioteca adicionada para realizar soma e subtracao

entity test_vending is  -- Declaracao da entidade
end test_vending;

architecture Bench of test_vending is

component vending
	port(
		clk: in std_logic; -- Clock do circuito
		reset, bot_sel, bot_mais, bot_menos, bot_inicio, bot_prog: in std_logic; -- Botoes externos para o usuário interagir com a maquina
		evt_moeda: in std_logic; -- Evento de entrada de moeda e identificacao pelo detector
		valor_moeda, valor_produto: in std_logic_vector(7 downto 0); -- Entrada de valor da moeda detetada
		lib_prod, lib_troco, lib_passagem_moeda: out std_logic; -- Sinais de controle da máquina para liberacao de produto, de troco e uma trava para evitar que moedas
		-- inseridas durante alguma operacao fiquem presas na maquina
		display_prod: out std_logic_vector(5 downto 0); -- A maquina e expansivel para ate 64 produtos. Essa saida mostra o produto no display
		display_valor: out std_logic_vector(7 downto 0); -- O valor do produto pode ser de ate 2,55 reais (0 ate 255 centavos). Essa saida mostra o preco do produto no display
		display_troco: out std_logic_vector(7 downto 0) -- Essa saida envia o valor da moeda para o liberador de troco (um equipamento parecido com o identificador de moedas, 
		-- mas que verifica o numero de moedas a serem liberadas e devolve para o cliente). O troco pode ser de ate 2,55 reais (0 ate 255 centavos)
	);
end component;
	
	-- Entradas simuladas
	signal T_clk: std_logic;
	signal T_reset, T_bot_sel, T_bot_mais, T_bot_menos, T_bot_inicio, T_bot_prog: std_logic := '0';
	signal T_evt_moeda: std_logic := '0';
	signal T_valor_moeda, T_valor_produto: std_logic_vector(7 downto 0) := (others=>'0');
	
	-- Saidas testadas
	signal T_lib_prod, T_lib_troco, T_lib_passagem_moeda: std_logic;
	signal T_display_prod: std_logic_vector(5 downto 0);
	signal T_display_valor: std_logic_vector(7 downto 0);
	signal T_display_troco: std_logic_vector(7 downto 0);

begin

    U1: vending port map(T_clk,T_reset,T_bot_sel, T_bot_mais, T_bot_menos, T_bot_inicio, T_bot_prog, T_evt_moeda, T_valor_moeda, T_valor_produto, T_lib_prod, T_lib_troco, T_lib_passagem_moeda, T_display_prod, T_display_valor, T_display_troco);
	
    Clk_sig: process
    begin
        T_clk<='1';			-- clock signal
        wait for 5 ns;
        T_clk<='0';
        wait for 5 ns;
    end process;

    process	

		variable err_cnt: integer :=0;

    begin
	
		-- Rotina do teste:
			-- Cadastro de um produto aleatório no sistema, com um preco
			-- Compra desse produto - 3 tentativas:
				-- Colocando mais dinheiro do que o necessário - testar recebimento do troco e do produto
				-- Colocando a quantia exata - testar o nao recebimento do troco e o recebimento do produto
				-- Colocando menos do que o necessário - testar a nao liberacao do produto e o nao recebimento de troco

		T_reset <= '1';
		wait for 20 ns;
		T_reset <= '0';
		wait for 20 ns;

----------------------------------
-- Teste 1 - Cadastramento
----------------------------------

        -- Teste do cadastro de preco de produto (teste no produto n 3 - indice 2)
		T_bot_inicio <= '1'; -- Clicar e segurar no botao inicio
		wait for 20 ns; -- Atraso simulado de tempo que o usuário leva para apertar dois botões
		T_bot_prog <= '1'; -- Clicar e segurar no botao de programacao

		wait for 50 ns;
		
		T_bot_inicio <= '0'; -- Soltar o botao inicio
		wait for 20 ns; -- Atraso simulado de tempo que o usuário leva para apertar dois botões
		T_bot_prog <= '0'; -- Soltar o botao de programacao
		
		-- Ambiente de programacao
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina
		
		-- Pressionar o botao 3 vezes
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000001") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000010") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000011") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		-- Incrementar um a mais para testar o botao de decremento
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000100") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_menos <= '1';
		wait for 20 ns;
		T_bot_menos <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000011") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina

		-- Carregamento de valores na entrada externa de preco (no caso, 1,75)
		
		T_valor_produto <= "10101111";
		
		wait for 50 ns;
		
		-- Pressionar o botao para alterar esse produto (o valor já está estável na entrada)
		
		T_bot_sel <= '1';
		wait for 50 ns;
		T_bot_sel <= '0';
		
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		-- Teste das saidas do estado
		if (T_display_prod /= "000011") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "10101111") then
			err_cnt := err_cnt + 1;
		end if;

----------------------------------
-- Teste 2 - Insercao de moedas e selecao do produto - entrada maior do que o valor do produto
----------------------------------		

		-- Voltar para o inicio e entrar em modo de vendas para testar o produto
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina
		
		T_bot_inicio <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_inicio <= '0'; -- Soltar o botao inicio
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
				
		-- Usuário insere moedas para o produto que ele deseja
			-- Primeiro caso, insere mais do que o necessário (2,00 reais - 2 moedas de 1 real)
		
		-- Supomos que o valor da moeda está disponivel 20 ns antes do evento (para estabilizar) e que o evento fica ativo por 50 ns;
		T_valor_moeda <= "01100100"; -- 1,00 real
		wait for 20 ns;
		T_evt_moeda <= '1';
		wait for 50 ns; -- 
		T_evt_moeda <='0';
		wait for 20 ns;
		T_valor_moeda <= "00000000";
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "01100100") then -- 1,00 real
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos
		
		T_valor_moeda <= "01100100";
		wait for 20 ns;
		T_evt_moeda <= '1';
		wait for 50 ns;
		T_evt_moeda <='0';
		wait for 20 ns;
		T_valor_moeda <= "00000000";
		
		wait for 50 ns;
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "11001000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos
		
		-- Clicar em continuar, para selecionar o produto

		T_bot_sel <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_sel <= '0'; -- Soltar o botao inicio
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '1') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		-- Pressionar o botao 3 vezes
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000001") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000010") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000011") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;

		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		-- Clicar em continuar, para confirmar a compra

		T_bot_sel <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_sel <= '0'; -- Soltar o botao inicio

		wait for 50 ns; -- Processamento do comparador
		
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_lib_troco = '0') then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_prod = '0') then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_troco /= "00011001") then
			err_cnt := err_cnt + 1;
		end if;
		
----------------------------------
-- Teste 3 - Insercao de moedas e selecao do produto - entrada de valor igual ao do produto
----------------------------------		
		
		-- Voltar para o inicio e entrar em modo de vendas para testar o produto
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina
		
		T_bot_inicio <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_inicio <= '0'; -- Soltar o botao inicio
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
				
		-- Usuário insere moedas para o produto que ele deseja
			-- Primeiro caso, insere mais do que o necessário (2,00 reais - 2 moedas de 1 real)
		
		-- Supomos que o valor da moeda está disponivel 20 ns antes do evento (para estabilizar) e que o evento fica ativo por 50 ns;
		T_valor_moeda <= "01100100"; -- 1,00 real
		wait for 20 ns;
		T_evt_moeda <= '1';
		wait for 50 ns; -- 
		T_evt_moeda <='0';
		wait for 20 ns;
		T_valor_moeda <= "00000000";
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "01100100") then -- 0,50 real
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos
		
		T_valor_moeda <= "00110010"; -- 0,50 real
		wait for 20 ns;
		T_evt_moeda <= '1';
		wait for 50 ns;
		T_evt_moeda <='0';
		wait for 20 ns;
		T_valor_moeda <= "00000000";
		
		wait for 50 ns;
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "11001000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		T_valor_moeda <= "00011001"; -- 0,25 real
		wait for 20 ns;
		T_evt_moeda <= '1';
		wait for 50 ns; -- 
		T_evt_moeda <='0';
		wait for 20 ns;
		T_valor_moeda <= "00000000";
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "01100100") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		
		-- Clicar em continuar, para selecionar o produto

		T_bot_sel <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_sel <= '0'; -- Soltar o botao inicio
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '1') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		-- Pressionar o botao 3 vezes
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000001") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000010") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000011") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;

		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		-- Clicar em continuar, para confirmar a compra

		T_bot_sel <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_sel <= '0'; -- Soltar o botao inicio

		wait for 50 ns; -- Processamento do comparador
		
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_lib_troco = '0') then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_prod = '0') then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_troco /= "00011001") then
			err_cnt := err_cnt + 1;
		end if;

----------------------------------
-- Teste 4 - Insercao de moedas e selecao do produto - entrada de valor inferior ao do produto
----------------------------------		
		
		-- Voltar para o inicio e entrar em modo de vendas para testar o produto
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina
		
		T_bot_inicio <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_inicio <= '0'; -- Soltar o botao inicio
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
				
		-- Usuário insere moedas para o produto que ele deseja
			-- Primeiro caso, insere mais do que o necessário (2,00 reais - 2 moedas de 1 real)
		
		-- Supomos que o valor da moeda está disponivel 20 ns antes do evento (para estabilizar) e que o evento fica ativo por 50 ns;
		T_valor_moeda <= "01100100"; -- 1,00 real
		wait for 20 ns;
		T_evt_moeda <= '1';
		wait for 50 ns; -- 
		T_evt_moeda <='0';
		wait for 20 ns;
		T_valor_moeda <= "00000000";
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "01100100") then -- 1,00 real
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos
		
		T_valor_moeda <= "00110010"; -- 0,50 real
		wait for 20 ns;
		T_evt_moeda <= '1';
		wait for 50 ns;
		T_evt_moeda <='0';
		wait for 20 ns;
		T_valor_moeda <= "00000000";
		
		wait for 50 ns;
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "11001000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos
		
		-- Clicar em continuar, para selecionar o produto

		T_bot_sel <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_sel <= '0'; -- Soltar o botao inicio
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '1') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		-- Pressionar o botao 3 vezes
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000001") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000010") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000011") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;

		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		-- Clicar em continuar, para confirmar a compra

		T_bot_sel <= '1'; -- Clicar no botao selecao
		wait for 20 ns;
		T_bot_sel <= '0'; -- Soltar o botao selecao

		wait for 50 ns; -- Processamento do comparador
		
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_lib_troco = '0') then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_prod = '0') then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_troco /= "00011001") then
			err_cnt := err_cnt + 1;
		end if;

		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dizendo que ele não possui crédito suficiente

		T_bot_inicio <= '1'; -- Clicar no botao inicio
		wait for 20 ns;
		T_bot_inicio <= '0'; -- Soltar o botao inicio

		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dizendo que ele não possui crédito suficiente

-- Colocar mais moedas

		T_valor_moeda <= "00011001"; -- 0,25 real
		wait for 20 ns;
		T_evt_moeda <= '1';
		wait for 50 ns; -- 
		T_evt_moeda <='0';
		wait for 20 ns;
		T_valor_moeda <= "00000000";
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_valor /= "01100100") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '0') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		
		-- Clicar em continuar, para selecionar o produto

		T_bot_sel <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_sel <= '0'; -- Soltar o botao inicio
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000000") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_passagem_moeda = '1') then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		-- Pressionar o botao 3 vezes
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000001") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000010") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;
		
		wait for 50 ns; -- Tempo entre apertar o botao novamente
		T_bot_mais <= '1';
		wait for 20 ns;
		T_bot_mais <= '0';
		
		-- Teste das saidas do estado
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_display_prod /= "000011") then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_valor /= "00000000") then
			err_cnt := err_cnt + 1;
		end if;

		wait for 50 ns; -- Tempo para o usuário visualizar valores no display da máquina dos creditos

		-- Clicar em continuar, para confirmar a compra

		T_bot_sel <= '1'; -- Clicar no botao inicio
		wait for 50 ns;
		T_bot_sel <= '0'; -- Soltar o botao inicio

		wait for 50 ns; -- Processamento do comparador
		
		wait for 20 ns; -- Aguardar a estabilizacao para realizar o teste
		if (T_lib_troco = '0') then
			err_cnt := err_cnt + 1;
		end if;
		if (T_lib_prod = '0') then
			err_cnt := err_cnt + 1;
		end if;
		if (T_display_troco /= "00011001") then
			err_cnt := err_cnt + 1;
		end if;




        wait;

    end process;

end Bench;

-----------------------------------------------------------------
configuration CFG_TB of test_vending is
	for Bench
	end for;
end CFG_TB;
-----------------------------------------------------------------
