-- ================================================================================
do $$ begin	raise info '01b - Define municípios dos imóveis do cerrado'; end; $$;
-- Filtra imóveis que estão no cerrado, baseado no polígono CAR
-- ================================================================================


DO $$
	DECLARE
		y record;
		z record;
		w record;
		munx varchar[];
		j int:=0;
		barra integer;
		porcentagem text;
    BEGIN
	
		
		
		FOR w IN
			SELECT 
					max(id) AS maximo 
				FROM 
					pssc.imoveis		
		LOOP
			FOR y IN
				SELECT 
						id		as id,
						geom	as geom
					FROM 
						pssc.imoveis i
					ORDER BY
						id
			LOOP
				barra=((y.id*50)/w.maximo);
				porcentagem=to_char(((y.id*100.00)/w.maximo)::numeric, '990D99');
				RAISE INFO '-- Definição de Municípios: Imóvel %/%
	% %░%', y.id, w.maximo,  porcentagem || '%', repeat('░',barra), repeat('▬',50-barra);
				munx:=null;
				j:=0;
				FOR z IN
					SELECT
							cd_mun
						FROM 
							psscx.municipios m
						WHERE
							ST_Intersects (y.geom, m.geom)
				LOOP
					munx[j]:=z.cd_mun;
					j:=j+1;
				END LOOP;
				UPDATE 
						pssc.imoveis 
					SET 
						municipios=munx 
					WHERE id=y.id;
			END LOOP;
		END LOOP;
	END;
$$;


