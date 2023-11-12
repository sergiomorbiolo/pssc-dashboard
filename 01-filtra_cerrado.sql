-- ================================================================================
do $$ begin	raise info '01 - Filtra imóveis do Cerrado'; end; $$;
-- Filtra imóveis que estão no cerrado, baseado no polígono CAR
-- ================================================================================

DROP TABLE IF EXISTS pssc.imoveis;
CREATE TABLE IF NOT EXISTS pssc.imoveis
(
	id				serial,
	car 			varchar(70),
	area 			float,
	uf 				varchar(2),
	municipio 		varchar(100),
	cod_municipio 	varchar(10),
	municipios		varchar[],
	modulos 		float,
	tipo 			varchar(3),
	situacao 		varchar(2),
	condicao 		varchar(150),
	geom 			geometry(Geometry,4674)
);


DO $$
	DECLARE
		x record;
		y record;
		z record;
		w record;
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
			EXECUTE format(
				'INSERT INTO
					pssc.imoveis (
						car, 
						area, 
						uf, 
						municipio, 
						cod_municipio, 
						modulos, 
						tipo, 
						situacao, 
						condicao, 
						geom
					)
				SELECT
						i.cod_imovel						as car, 
						i.num_area							as area, 
						i.cod_estado						as uf, 
						i.nom_munici						as municipio, 
						i.cod_mun							as cod_municipio,
						i.num_modulo						as modulos, 
						i.tipo_imove						as tipo, 
						i.situacao							as situacao, 
						i.condicao_i						as condicao, 
						ST_Multi(ST_MakeValid(i.geometry))	as geom
					FROM 
						car_' || x.uf || '.' || x.uf ||'_area_imovel i,
						public.mam_bioma c
					WHERE
						ST_Intersects(i.geometry,c.geom) 
						AND c.bioma=''Cerrado'' 
						-- AND i.nom_munici=''Sorriso'' 
						-- AND i.cod_estado=''MT''
						-- AND i.num_modulo>=4
					ORDER BY
						i.cod_imovel'
			);
		END LOOP;
		
		
