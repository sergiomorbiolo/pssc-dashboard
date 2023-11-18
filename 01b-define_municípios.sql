-- ================================================================================
do $$ begin	raise info '01b - Define Municípios'; end; $$;
-- ================================================================================

DO $$
	DECLARE
		x record;
	BEGIN
        FOR x IN 
			SELECT 
				id,
				cod_municipio,
				municipio,
				municipios
			FROM
				psscx.car_mun
			ORDER BY
				id
		LOOP
			UPDATE
					pssc.imoveis
				SET
					municipios=x.municipios
				WHERE
					cod_municipio=x.cod_municipio;
			RAISE INFO '-- % % - %', x.id, x.municipio, x.municipios;
		END LOOP;
	END;
$$;

		
		
