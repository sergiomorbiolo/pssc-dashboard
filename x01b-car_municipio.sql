-- ================================================================================
do $$ begin	raise info 'x01 - Filtra e Aglutina imóveis por município'; end; $$;
-- Aglutina os imóveis registrados no CAR para cada município
-- ================================================================================

DROP TABLE IF EXISTS psscx.car_mun;
CREATE TABLE IF NOT EXISTS psscx.car_mun
(
	id serial,
    cod_municipio text COLLATE pg_catalog."default",
    municipio text COLLATE pg_catalog."default",
    uf text COLLATE pg_catalog."default",
    geom geometry(Geometry,4674)
);


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
					psscx.municipios
		LOOP
			FOR x IN 
				SELECT
						m.cd_mun 			as cod_municipio,
						m.nm_mun 			as municipio,
						m.sigla 			as uf,
						m.geom				as geom
					FROM
						psscx.municipios m
-- 					WHERE
-- 						sigla='AC'
					ORDER BY
						cd_mun
			LOOP
				numero:=numero+1;
				RAISE INFO '-- %/% % - % %', numero, y.total, upper(x.uf), x.cod_municipio, x.municipio;
				INSERT INTO psscx.car_mun (
						cod_municipio,
						municipio,
						uf,
						geom
					)
					SELECT
							x.cod_municipio		as cod_municipio,
							x.municipio			as municipio,
							x.uf				as uf,
							ST_Union(x.geom,c.geom)
						FROM
							psscx.temp_car_mun c
						WHERE
							c.cod_municipio=x.cod_municipio
				;
			END LOOP;
		END LOOP;
	END;
$$;