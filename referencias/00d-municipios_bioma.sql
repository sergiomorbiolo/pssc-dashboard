-- ================================================================================
do $$ begin	raise info '00d - Define municípios do Cerrado'; end; $$;
-- Define os municpios do Cerrado brasileiro
-- ================================================================================

ALTER TABLE psscx.municipios DROP COLUMN IF EXISTS bioma;
ALTER TABLE psscx.municipios ADD COLUMN IF NOT EXISTS bioma varchar(35);

update psscx.municipios set bioma='Outros';

update psscx.municipios m set bioma='Área de Influência do Cerrado' from public.mam_bioma b WHERE ST_Intersects(m.geom, b.geom) AND b.bioma='Cerrado';

update psscx.municipios m set bioma='Parcialmente Cerrado' from public.mam_bioma b WHERE ST_Intersects(m.geom, b.geom) AND b.bioma='Cerrado' AND ST_Area(ST_Intersection(m.geom,b.geom))>(ST_Area(m.geom)*0.6);

update psscx.municipios m set bioma='Cerrado' from public.mam_bioma b WHERE ST_Within(m.geom, b.geom) AND b.bioma='Cerrado'