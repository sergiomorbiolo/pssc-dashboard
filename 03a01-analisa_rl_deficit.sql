-- ================================================================================
do $$ begin	raise info '03a - Analisa Reserva legal';
	raise info '		parte 1: Levanta RL Deficitária


'; end; $$;
-- Recorta o polígono de Reserva Legal por propriedade rural
-- ================================================================================

DO $$
	DECLARE
		x record;
		y record;
		barra integer;
		porcentagem text;
		erro text;

    BEGIN
		ALTER TABLE pssc.rl DROP COLUMN IF EXISTS rl_area;
		ALTER TABLE pssc.rl DROP COLUMN IF EXISTS rl_deficit_area;
		ALTER TABLE pssc.rl DROP COLUMN IF EXISTS rl_deficit_geom;
		
		ALTER TABLE pssc.rl ADD COLUMN IF NOT EXISTS rl_area double precision;
		ALTER TABLE pssc.rl ADD COLUMN IF NOT EXISTS rl_deficit_area double precision;
		ALTER TABLE pssc.rl ADD COLUMN IF NOT EXISTS rl_deficit_geom geometry(Geometry,4674);

		FOR y IN
			SELECT
					count(*) 	AS maximo
				from
					pssc.rl
		LOOP
			FOR x IN
				SELECT 
						rl.id		as id, 
						rl.car		as rl_car, 
						vn.car		as vn_car,
						rl.geom		as rl_geom,
						vn.geom		as vn_geom
					FROM 
						pssc.rl rl INNER JOIN
						pssc.vn vn ON
						rl.car=vn.car
					ORDER BY
						rl.id
-- 					limit 100
			LOOP
				barra=((x.id*50)/y.maximo);
				porcentagem=to_char(((x.id*100.00)/y.maximo)::numeric, '990D99');
				RAISE INFO '%/% % %░%     %', x.id, y.maximo, porcentagem || '%', repeat('░',barra), repeat('▬',50-barra), x.rl_car;
				WITH temp AS (
					SELECT
						ST_Multi(ST_CollectionExtract(ST_Union(ST_Difference(x.rl_geom,x.vn_geom,0.000000001)), 3))		AS deficit
				)
				UPDATE
						pssc.rl
					SET
						rl_area=(ST_Area(x.rl_geom::geography)/10000),
						rl_deficit_area=(ST_Area(temp.deficit::geography)/10000),
						rl_deficit_geom=temp.deficit
					FROM
						temp
					WHERE
						car=x.rl_car;
			END LOOP;
		END LOOP;
	END;
$$;









