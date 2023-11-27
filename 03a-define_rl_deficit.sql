-- ================================================================================
do $$ begin	raise info '03a - Define reserva legal deficitária


'; end; $$;
-- ================================================================================

DO $$
	DECLARE
		x record;
		y record;
		erro text;
    BEGIN
		FOR y IN
			SELECT uf from pssc.ufs ufs ORDER BY uf
		LOOP
			raise info '%', y.uf;
			EXECUTE FORMAT ('
				ALTER TABLE pssc.imoveis_%s DROP COLUMN IF EXISTS rl_deficit_erro', 
					y.uf
			);
			EXECUTE FORMAT ('
				ALTER TABLE pssc.imoveis_%s ADD COLUMN IF NOT EXISTS rl_deficit_erro text', 
					y.uf
			);
			FOR x IN
				EXECUTE FORMAT ('
					SELECT 
							id,
							car,
							rl_geom,
							vn_geom
						from 
							pssc.imoveis_%s i ORDER BY uf', 
						y.uf
				)
			LOOP
				BEGIN
					raise info '%', x.car;
					EXECUTE FORMAT ('
						UPDATE 
								pssc.imoveis_%s
							SET
								rl_deficit_geom=ST_Difference(rl_geom,vn_geom),
								rl_deficit_area=ST_Area(ST_Difference(rl_geom,vn_geom)::geography)/10000,
								rl_deficit_erro=''ok''
							WHERE
								car=''%s''
								', 
							y.uf,
							x.car
					);
				EXCEPTION WHEN OTHERS THEN
					BEGIN
						erro=SQLERRM;
						raise info 'ERRO! %
						%', erro, x.car;
						EXECUTE FORMAT ('
							UPDATE 
									pssc.imoveis_%s
								SET
									rl_deficit_geom=ST_Difference(ST_Makevalid(rl_geom),ST_Makevalid(vn_geom))
									rl_deficit_area=ST_Area(ST_Difference(rl_geom,vn_geom)::geography)/10000,
									rl_deficit_erro=''%s''
								WHERE
									car=''%s''
									', 
								y.uf,
								erro,
								x.car
						);
					EXCEPTION WHEN OTHERS THEN
						BEGIN
							erro=SQLERRM;
							raise info 'ERRO! %
							%', erro, x.car;
							EXECUTE FORMAT ('
								UPDATE 
										pssc.imoveis_%s
									SET
										rl_deficit_geom=null,
										rl_deficit_area=null,
										rl_deficit_erro=''%s''
									WHERE
										car=''%s''
										', 
									y.uf,
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
