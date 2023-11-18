-- ================================================================================
do $$ begin	raise info '01b - Define Municípios'; end; $$;
-- ================================================================================

DO $$
	DECLARE
		x record;
	BEGIN
        FOR x IN 
			SELECT 
				cod_municipio,
				municipio,
				municipios
			FROM
				psscx.car_mun
		LOOP
			UPDATE
					pssc.imoveis
				SET
					municipios=x.municipios
				WHERE
					cod_municipio=x.cod_municipio;
			RAISE INFO '-- % - %', x.municipio, x.municipios;
		END LOOP;
	END;
$$;

		
		
