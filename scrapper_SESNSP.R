# webscrapping para obtener las bases del SESNSP
library(xml2)
library(rvest)

# Página del secretariado
url <- "https://www.gob.mx/sesnsp/acciones-y-programas/datos-abiertos-de-incidencia-delictiva?state=published"

# lee la página
pg <- read_html(url)

# filtro de la página donde tenga el nodo "a" ya que cuando el nodo es "<a>" indica que hay un vínculo simple
# (la a es la abreviatura de la palabra inglesa «anchor» («ancla»)) y se usa Para convertir algún texto dentro de un párrafo en un vínculo
# y como las bases están en un link de google drive me interesan los vínculos.
# href es un atributo que se utiliza para hacer referencia a otro documento o un link
# se pasa en formato tabular y nos interesa solo los que dicen "drive" ya que el link se comparte a traves de una carpeta de drive
links <- html_attr(html_nodes(pg, "a"),"href") |> 
  as_tibble() |> 
  filter(str_detect(value,"drive")) |>
  mutate(link=1:n())

# Por el órden en el que se presentan en la página los links de interés son:
# El primer link corresponde a: IDEFC_NM_Mes.csv
# El cuarto link corresponde a: IDVF_NM_mes.csv
bases_link <- links|>
  filter(link%in%c(1,4))

# Con la librería Google Drive Descargamos el archivo en un archivo temporal
# usa los corchetes para extraer el primer link y el segundo


carpetas <- googledrive::drive_download(bases_link[1,1]$value,overwrite = T)
victimas <- googledrive::drive_download(bases_link[2,1]$value,overwrite = T)

carpetas <- read.csv(carpetas$local_path,
                     encoding = "latin-1") %>%
  as_tibble() %>%
  janitor::clean_names() %>%
  mutate(across(enero:diciembre,as.numeric))


victimas <- read.csv(victimas$local_path,
                     encoding = "latin-1") %>%
  as_tibble() %>%
  janitor::clean_names() %>%
  mutate(across(enero:diciembre,as.numeric))
