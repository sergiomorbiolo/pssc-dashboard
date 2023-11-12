-- ================================================================================
do $$ begin	raise info '02 - Recorta Reserva Legal


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
		tabela_fonte text;
		tabela_alvo text;
		municipiosx text;
    BEGIN
		tabela_alvo='ac';
		tabela_fonte='area_consolidada';
		EXECUTE FORMAT ('
			DROP TABLE IF EXISTS pssc.%s
		', tabela_alvo);
		EXECUTE FORMAT ('
			CREATE TABLE IF NOT EXISTS pssc.%s
				(
					id		integer,
					car 	varchar(70),
					geom 	geometry(Geometry,4674),
					erro	text
				)
		', tabela_alvo);
		FOR y IN
			SELECT
					max(id) 	AS maxid
				from
					pssc.imoveis
		LOOP
			FOR x IN 
				SELECT 
						i.id			AS id,
						i.car			AS car,
						lower(i.uf)		AS uf, 
						i.cod_municipio	AS cod_municipio,
-- 						i.municipios	AS municipios,
						i.geom 			AS geom 
					FROM 
						pssc.imoveis i
					ORDER BY
						id
			LOOP
				BEGIN
					
					barra=((x.id*50)/y.maxid);
					porcentagem=to_char(((x.id*100.00)/y.maxid)::numeric, '990D99');
-- 					municipiosx=array_to_string(x.municipios, ''',''');
					municipiosx=x.cod_municipio;
					EXECUTE format(
						'INSERT INTO
							pssc.%s
						SELECT
								%s																						as id, 
								%L																						as car, 
								ST_Multi(ST_CollectionExtract(ST_Union(ST_Intersection(a.geometry::geometry, %L)),3))	as geom,
								''ok''																					as erro
							FROM 
								car_%s.%s_%s a
							WHERE
								ST_Intersects(a.geometry::geometry,%L)
								-- AND a.cod_mun in (''%s'')
							ORDER BY
								id desc',
						tabela_alvo,
						x.id,
						x.car,
						x.geom,
						x.uf,
						x.uf,
						tabela_fonte,
						x.geom,
						municipiosx
					);
					RAISE INFO '% %░%     %',  porcentagem || '%', repeat('░',barra), repeat('▬',50-barra), x.car;
					RAISE INFO '
					
					';
				EXCEPTION WHEN OTHERS THEN
					BEGIN
						erro=SQLERRM;
						barra=((x.id*50)/y.maxid);
						porcentagem=to_char(((x.id*100.00)/y.maxid)::numeric, '990D99');
						EXECUTE format(
							'INSERT INTO
								pssc.%s
							SELECT
									%s																									as id, 
									%L																									as car, 
									ST_Multi(ST_CollectionExtract(ST_Union(ST_Intersection(ST_Makevalid(a.geometry)::geometry, %L)),3))	as geom,
									%L																									as erro
								FROM 
									car_%s.%s_%s a
								WHERE
									ST_Intersects(ST_Makevalid(a.geometry)::geometry,%L)
									--AND a.cod_mun in (''%s'')
								ORDER BY
									id desc',
							tabela_alvo,
							x.id,
							x.car,
							x.geom,
							erro,
							x.uf,
							x.uf,
							tabela_fonte,
							x.geom,
							municipiosx
						);					
						RAISE INFO '% %▌%     %',  porcentagem || '%', repeat('█',barra), repeat('▬',50-barra), x.car;
						RAISE NOTICE '%', erro;
						RAISE INFO '

						';
					EXCEPTION WHEN OTHERS THEN
						BEGIN
							erro=SQLERRM;
							barra=((x.id*50)/y.maxid);
							porcentagem=to_char(((x.id*100.00)/y.maxid)::numeric, '990D99');
							EXECUTE format(
								'INSERT INTO
									pssc.%s
								SELECT
										%s		as id, 
										%L		as car, 
										NULL	as geom,
										%L		as erro
								',
								tabela_alvo,
								x.id,
								x.car,
								erro
							);					
							RAISE INFO '% %X%     %',  porcentagem || '%', repeat('X',barra), repeat('▬',50-barra), x.car;
							RAISE NOTICE '%', erro;
							RAISE INFO '

							';
						END;					
					END;
				END;
			END LOOP;
		END LOOP;
	END;
$$;



