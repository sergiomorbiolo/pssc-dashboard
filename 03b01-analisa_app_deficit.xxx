-- ================================================================================
do $$ begin	raise info '03b - Analisa APP';
	raise info '		parte 1: Levanta APP Deficitária


'; end; $$;
-- ================================================================================

DO $$
	DECLARE
		x record;
		y record;
		barra integer;
		porcentagem text;
		erro text;

    BEGIN
		ALTER TABLE pssc.app DROP COLUMN IF EXISTS app_area;
		ALTER TABLE pssc.app DROP COLUMN IF EXISTS app_deficit_area;
		ALTER TABLE pssc.app DROP COLUMN IF EXISTS app_deficit_geom;
		
		ALTER TABLE pssc.app ADD COLUMN IF NOT EXISTS app_area double precision;
		ALTER TABLE pssc.app ADD COLUMN IF NOT EXISTS app_deficit_area double precision;
		ALTER TABLE pssc.app ADD COLUMN IF NOT EXISTS app_deficit_geom geometry(Geometry,4674);

		FOR y IN
			SELECT
					count(*) 	AS maximo
				from
					pssc.app
		LOOP
			FOR x IN
				SELECT 
						app.id		as id, 
						app.car		as app_car, 
						vn.car		as vn_car,
						app.geom		as app_geom,
						vn.geom		as vn_geom
					FROM 
						pssc.app app INNER JOIN
						pssc.vn vn ON
						app.car=vn.car
					ORDER BY
						app.id
-- 					limit 100
			LOOP
				barra=((x.id*50)/y.maximo);
				porcentagem=to_char(((x.id*100.00)/y.maximo)::numeric, '990D99');
				RAISE INFO '%/% % %░%     %', x.id, y.maximo, porcentagem || '%', repeat('░',barra), repeat('▬',50-barra), x.app_car;
				WITH temp AS (
					SELECT
						ST_Multi(ST_CollectionExtract(ST_Union(ST_Difference(x.app_geom,x.vn_geom,0.000000001)), 3))		AS deficit
				)
				UPDATE
						pssc.app
					SET
						app_area=(ST_Area(x.app_geom::geography)/10000),
						app_deficit_area=(ST_Area(temp.deficit::geography)/10000),
						app_deficit_geom=temp.deficit
					FROM
						temp
					WHERE
						car=x.app_car;
			END LOOP;
		END LOOP;
	END;
$$;









