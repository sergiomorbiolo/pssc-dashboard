-- ================================================================================
do $$ begin	raise info '01c - Separa imóveis por UF


'; end; $$;
-- ================================================================================

DO $$
	DECLARE
		x record;
	BEGIN
		FOR x IN 
			SELECT uf FROM pssc.ufs
		LOOP
			EXECUTE format('
				DROP TABLE IF EXISTS pssc.imoveis_%s
			',
				x.uf
			);
			EXECUTE format('
				CREATE TABLE IF NOT EXISTS pssc.imoveis_%s AS
					SELECT 
							id, 
							car, 
							area, 
							uf, 
							municipio, 
							cod_municipio, 
							municipios, 
							modulos, 
							tipo, 
							situacao, 
							condicao, 
							geom
						FROM 
							pssc.imoveis
						WHERE
							uf=''%s''
						;
			',
				x.uf,
				UPPER(x.uf)
			);
			RAISE INFO '%

			', x.uf;
		END LOOP;
   END;
$$