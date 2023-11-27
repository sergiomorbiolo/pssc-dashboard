-- ================================================================================
do $$ begin	raise info '03a - Define reserva legal deficitária


'; end; $$;
-- ================================================================================

DO $$
	DECLARE
		x record;
		y record;
    BEGIN
		FOR y IN
			SELECT uf from pssc.ufs ufs ORDER BY uf
		LOOP
			raise info '%', y.uf;
			FOR y IN
				SELECT uf from pssc.ufs ufs ORDER BY uf
			LOOP
				EXECUTE FORMAT ('
					UPDATE pssc.imoveis_%s SET rl_deficit_geom=ST_Difference(rl_geom,vn_geom);', 
					y.uf);
			END LOOP;
		END LOOP;
	END;
$$;
