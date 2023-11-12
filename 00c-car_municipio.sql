-- ================================================================================
do $$ begin	raise info 'x01 - Filtra e Aglutina imóveis por município'; end; $$;
-- Aglutina os imóveis registrados no CAR para cada município
-- ================================================================================



DO $$
	DECLARE
		x record;
		y record;
		z record;
		munx varchar[];
		numero int;
    BEGIN
		FOR z IN
			SELECT
					count(*) as maximo 
				from 
					psscx.car_mun
		LOOP
-- 			RAISE INFO '%', z.maximo;
	
	
			FOR x IN
				SELECT
						id, 
						cod_municipio, 
						municipio, 
						uf, 
						geom
					FROM 
						psscx.car_mun
					ORDER BY 
						id
			LOOP
-- 				RAISE INFO '%', x.id;
				munx:=null;
				numero:=0;
				FOR y IN
					SELECT 
							id as id,
							cd_mun as cod_munx
						FROM
							psscx.municipios m
						WHERE
							ST_Intersects(m.geom,x.geom)
				LOOP
					munx[numero]:=y.cod_munx;
					numero:=numero+1;
				END LOOP;
				UPDATE
						psscx.car_mun
					SET
						municipios=munx
					WHERE
						cod_municipio=x.cod_municipio;
				RAISE INFO '%/% %', x.id, z.maximo, x.municipio;
			END LOOP;
		
		
		
		
		END LOOP;
	END;
$$;