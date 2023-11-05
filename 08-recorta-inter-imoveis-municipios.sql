-- ================================================================================
do $$ begin	raise info 'x01 - Filtra e Aglutina imóveis por município'; end; $$;
-- Aglutina os imóveis registrados no CAR para cada município
-- ================================================================================

DROP TABLE IF EXISTS pssc.imoveis_mun;
CREATE TABLE IF NOT EXISTS pssc.imoveis_mun
	AS
		SELECT
				id				AS id,
				car				AS car,
				uf				AS uf,
				municipio		AS municipio,
				cod_municipio	AS cod_municipio,
				geom			AS geom
			FROM 
				pssc.imoveis
			LIMIT 0
;

DO $$
	DECLARE
		x record;
		y record;
		numero integer:=0;
    BEGIN
		FOR y IN
			SELECT
					count(*)	as total
				from
					public.br_municipios_2021
		LOOP
			FOR x IN 
				SELECT
						m.cd_mun 			as cod_municipio,
						m.nm_mun 			as municipio,
						m.sigla 			as uf,
						m.geom				as geom
					FROM
						public.br_municipios_2021 m
-- 					WHERE
-- 						sigla='AC'
					ORDER BY
						cd_mun
			LOOP
				numero:=numero+1;
				RAISE INFO '-- %/% % - % %', numero, y.total, upper(x.uf), x.cod_municipio, x.municipio;
				INSERT INTO pssc.imoveis_mun (
						car,
						uf,
						municipio,
						cod_municipio,
						geom
					)
					SELECT
							i.car				AS car,
							x.uf				AS uf,
							x.municipio			AS municipio,
							x.cod_municipio		AS cod_municipio,
							ST_Multi(ST_CollectionExtract(ST_MakeValid(ST_Intersection(x.geom,i.geom)), 3))
						FROM
							pssc.imoveis i
						WHERE
							ST_Intersects(x.geom,i.geom)
				;
			END LOOP;
		END LOOP;
	END;
$$;



