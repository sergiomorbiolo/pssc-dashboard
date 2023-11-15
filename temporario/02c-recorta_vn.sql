-- ================================================================================
do $$ begin	raise info '02c - Recorta Vegetação Nativa


'; end; $$;
-- Recorta o polígono de Vegetação Nativa por propriedade rural
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
		tabela_alvo='vn';
		tabela_fonte='vegetacao_nativa';
		EXECUTE FORMAT ('
			DROP TABLE IF EXISTS ptemp.%s
		', tabela_alvo);
		EXECUTE FORMAT ('
			CREATE TABLE IF NOT EXISTS ptemp.%s
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
					ptemp.imoveis
		LOOP
			FOR x IN 
				SELECT 
						i.id			AS id,
						i.car			AS car,
						lower(i.uf)		AS uf, 
						i.cod_municipio	AS cod_municipio,
						m.municipios	AS municipios,
						i.geom 			AS geom 
					FROM 
						ptemp.imoveis i LEFT JOIN
						psscx.car_mun m ON
						i.cod_municipio = m.cod_municipio
					ORDER BY
						id
			LOOP
				BEGIN
					
					barra=((x.id*50)/y.maxid);
					porcentagem=to_char(((x.id*100.00)/y.maxid)::numeric, '990D99');
					municipiosx=array_to_string(x.municipios, ''',''');
-- 					municipiosx=x.cod_municipio;
					EXECUTE format(
						'INSERT INTO
							ptemp.%s
						SELECT
								%s																						as id, 
								%L																						as car, 
								ST_Multi(ST_CollectionExtract(ST_Union(ST_Intersection(a.geometry::geometry, %L)),3))	as geom,
								''ok''																					as erro
							FROM 
								car_%s.%s_%s a
							WHERE
								ST_Intersects(a.geometry::geometry,%L)
								AND a.cod_mun in (''%s'')
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
					RAISE INFO '%/% % %░%     %',  x.id, y.maxid, porcentagem || '%', repeat('░',barra), repeat('▬',50-barra), x.car;
					RAISE INFO '
					
					';
				EXCEPTION WHEN OTHERS THEN
					BEGIN
						erro=SQLERRM;
						barra=((x.id*50)/y.maxid);
						porcentagem=to_char(((x.id*100.00)/y.maxid)::numeric, '990D99');
						EXECUTE format(
							'INSERT INTO
								ptemp.%s
							SELECT
									%s																									as id, 
									%L																									as car, 
									ST_Multi(ST_CollectionExtract(ST_Union(ST_Intersection(ST_Makevalid(a.geometry)::geometry, %L)),3))	as geom,
									%L																									as erro
								FROM 
									car_%s.%s_%s a
								WHERE
									ST_Intersects(ST_Makevalid(a.geometry)::geometry,%L)
									AND a.cod_mun in (''%s'')
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
						RAISE INFO '%/% % %▌%     %',  x.id, y.maxid, porcentagem || '%', repeat('█',barra), repeat('▬',50-barra), x.car;
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
									ptemp.%s
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



