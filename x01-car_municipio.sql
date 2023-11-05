-- ================================================================================
do $$ begin	raise info 'x01 - Filtra e Aglutina imóveis por município'; end; $$;
-- Aglutina os imóveis registrados no CAR para cada município
-- ================================================================================

DROP TABLE IF EXISTS psscx.car_mun;
CREATE TABLE IF NOT EXISTS psscx.car_mun
(
    cod_municipio text COLLATE pg_catalog."default",
    municipio text COLLATE pg_catalog."default",
    uf text COLLATE pg_catalog."default",
    geom geometry(Geometry,4674)
);


DO $$
	DECLARE
		x record;
		y record;
		z record;
		munx varchar[];
		j int:=0;
    BEGIN
        FOR x IN 
			SELECT 
					lower(u.sigla) AS uf, 
					u.nm_uf AS uf_nome 
				FROM 
					public.br_uf_2021 u
				ORDER BY
					uf
		LOOP
			RAISE INFO '-- % - %', upper(x.uf), x.uf_nome;
			EXECUTE format('
				INSERT INTO psscx.car_mun
				select cod_mun as cod_municipio,
					nom_munici as municipio,
					cod_estado as uf,
					ST_Multi(ST_CollectionExtract(ST_Union(ST_MakeValid(geometry)))) as geom
				from
					car_%s.%s_area_imovel
				GROUP BY
					cod_mun, nom_munici, cod_estado
			',
			x.uf,
			x.uf)
			;
		END LOOP;
	END;
$$;