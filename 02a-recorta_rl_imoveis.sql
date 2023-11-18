-- ================================================================================
do $$ begin	raise info '02 - Recorta Reserva Legal


'; end; $$;
-- ================================================================================

DO $$
	DECLARE
		x record;
		y record;
		erro text;
		tabela_fonte text:='reserva_legal';
		tabela_alvo text:='rl';
		municipiosx text;
    BEGIN
		FOR y IN
			SELECT uf FROM pssc.ufs ORDER BY uf
		LOOP
		
		
		
			EXECUTE FORMAT ('
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_geom;
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_area;
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_erro;
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_deficit_geom;
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_deficit_area;
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_geom;
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_area;
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_erro;
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_deficit_geom;
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS %s_deficit_area;
			', 
				y.uf, tabela_alvo,
				y.uf, tabela_alvo,
				y.uf, tabela_alvo,
				y.uf, tabela_alvo,
				y.uf, tabela_alvo,
				y.uf, tabela_fonte,
				y.uf, tabela_fonte,
				y.uf, tabela_fonte,
				y.uf, tabela_fonte,
				y.uf, tabela_fonte
			);
			EXECUTE FORMAT ('
				ALTER TABLE pssc.imoveis_%s ADD COLUMN IF NOT EXISTS %s_geom geometry(Geometry,4674);
				ALTER TABLE pssc.imoveis_%s ADD COLUMN IF NOT EXISTS %s_area double precision;
				ALTER TABLE pssc.imoveis_%s ADD COLUMN IF NOT EXISTS %s_erro text;
				ALTER TABLE pssc.imoveis_%s ADD COLUMN IF NOT EXISTS %s_deficit_geom geometry(Geometry,4674);
				ALTER TABLE pssc.imoveis_%s ADD COLUMN IF NOT EXISTS %s_deficit_area double precision;
			', 
				y.uf, tabela_alvo,
				y.uf, tabela_alvo,
				y.uf, tabela_alvo,
				y.uf, tabela_alvo,
				y.uf, tabela_alvo
			);
			FOR x IN 
				SELECT 
						i.id			AS id,
						i.car			AS car,
						lower(i.uf)		AS uf, 
						i.cod_municipio	AS cod_municipio,
						i.municipios	AS municipios,
						i.geom 			AS geom 
					FROM 
						pssc.imoveis i
					WHERE
						uf=upper(y.uf)
					ORDER BY
						id
-- 	 				LIMIT 10
			LOOP
				BEGIN
					municipiosx=array_to_string(x.municipios, ''',''');
					EXECUTE format(
						'UPDATE
								pssc.imoveis_%s
							SET
								%s_geom=temp.geom,
								%s_erro=''ok''
							FROM (
								SELECT
										ST_Union(ST_Intersection(a.geometry::geometry, %L))	as geom
									FROM 
										car_%s.%s_%s a
									WHERE
										ST_Intersects(a.geometry::geometry,%L)
										AND a.cod_mun in (''%s'')
							) as temp
							WHERE
								car=''%s''
						',
						lower(y.uf),
						tabela_alvo,
						tabela_alvo,
						x.geom,
						x.uf,
						x.uf,
						tabela_fonte,
						x.geom,
						municipiosx,
						x.car
					);
					RAISE INFO '% - %

					', x.id, x.car;
				EXCEPTION WHEN OTHERS THEN
					BEGIN
						erro=SQLERRM;
						municipiosx=array_to_string(x.municipios, ''',''');
						EXECUTE format(
							'UPDATE
									pssc.imoveis_$s
								SET
									%s_geom=temp.geom,
									%s_erro=%L
								FROM (
									SELECT
											ST_Union(ST_Intersection(ST_Makevalid(a.geometry)::geometry, %L))	as geom
										FROM 
											car_%s.%s_%s a
										WHERE
											ST_Intersects(a.geometry::geometry,%L)
											AND a.cod_mun in (''%s'')
								)
								WHERE
									car=''%s''
							',
							lower(y.uf),
							tabela_alvo,
							tabela_alvo,
							erro,
							x.geom,
							x.uf,
							x.uf,
							tabela_fonte,
							x.geom,
							municipiosx,
							x.car
						);
						RAISE INFO '% - %
						%

						', x.id, x.car, erro;

					EXCEPTION WHEN OTHERS THEN
						BEGIN
							erro=SQLERRM;
							municipiosx=array_to_string(x.municipios, ''',''');
							RAISE INFO '% - %

							', x.id, x.car;
							EXECUTE format(
								'UPDATE
										pssc.imoveis_%s
									SET
										%s_geom=NULL,
										%s_erro=%L
									WHERE
										car=''%s''
								',
								lower(y.uf),
								tabela_alvo,
								tabela_alvo,
								erro,
								x.car
							);
						END;					
					END;
				END;
			END LOOP;
			
			
			
			
		END LOOP;	
	END;
$$;
