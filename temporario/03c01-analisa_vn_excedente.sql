-- ================================================================================
do $$ begin	raise info '03c - Analisa Vegetação Nativa';
	raise info '		parte 1: Levanta VN Excedente


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
		ALTER TABLE ptemp.vn DROP COLUMN IF EXISTS vn_area;
		ALTER TABLE ptemp.vn DROP COLUMN IF EXISTS vn_excedente_area;
		ALTER TABLE ptemp.vn DROP COLUMN IF EXISTS vn_excedente_geom;
		
		ALTER TABLE ptemp.vn ADD COLUMN IF NOT EXISTS vn_area double precision;
		ALTER TABLE ptemp.vn ADD COLUMN IF NOT EXISTS vn_excedente_area double precision;
		ALTER TABLE ptemp.vn ADD COLUMN IF NOT EXISTS vn_excedente_geom geometry(Geometry,4674);

		FOR y IN
			SELECT
					count(*) 	AS maximo
				from
					ptemp.vn
		LOOP
			FOR x IN
				SELECT 
						vn.id		as id, 
						vn.car		as vn_car, 
						rl.car		as rl_car,
						app.car		as app_car,
						vn.geom		as vn_geom,
						rl.geom		as rl_geom,
						app.geom	as app_geom
					FROM 
						ptemp.vn vn LEFT JOIN
						ptemp.rl rl ON
						vn.car=rl.car LEFT JOIN
						ptemp.app app ON
						vn.car=app.car
					ORDER BY
						vn.id
-- 					limit 100
			LOOP
				barra=((x.id*50)/y.maximo);
				porcentagem=to_char(((x.id*100.00)/y.maximo)::numeric, '990D99');
				RAISE INFO '% %░%     %',  porcentagem || '%', repeat('░',barra), repeat('▬',50-barra), x.vn_car;
				WITH temp AS (
					SELECT
						ST_Multi(ST_CollectionExtract(ST_Union(x.rl_geom,x.app_geom)))		AS app_rl
				)
				UPDATE
						ptemp.vn
					SET
						app_rl_geom=temp.app_rl
					FROM
						temp
					WHERE
						car=x.vn_car;
			END LOOP;
		END LOOP;
	END;
$$;









