library(tictoc)
library(tidyverse)
library(furrr)

plan("multisession", workers = 8)

datos_paises <- gapminder::gapminder

# Que funcione para 1 -----------------------------------------------------


rmarkdown::render(input = "reporte/reporte_template.Rmd", 
                  params = list(pais = "Chile"),
                  output_dir = "reporte/", 
                  output_file = "reporte_chile.docx"
                  )

# Ahora hacemos la función ------------------------------------------------

crea_reporte <- function(pais){
  
  rmarkdown::render(input = "reporte/reporte_template.Rmd", 
                              params = list(pais = pais),
                              output_dir = "reporte/", 
                              output_file = paste0("reporte_", janitor::make_clean_names(pais), ".docx"))
  }

crea_reporte("Peru")



crea_reporte_carpeta <- function(pais, carpeta){
  
  rmarkdown::render(input = "reporte/reporte_template.Rmd", 
                    params = list(pais = pais),
                    output_dir = paste("reporte/", carpeta), 
                    output_file = paste0("/reporte_", janitor::make_clean_names(pais), ".docx"))
}

crea_reporte_carpeta("Peru", "a")

#

# Esto que sigue no es independiente --------------------------------------

# Pero cuando lo hago en serie (no paralelo) con map, funciona bien


tic()
map(as.character(unique(datos_paises$country)), ~crea_reporte_carpeta(.x, "no_paralelo"))
toc()


# Se cae porque no es independiente al intentar escribir el mismo archivo en la misma carpeta

tic()
furrr::future_map(as.character(unique(datos_paises$country)), ~crea_reporte_carpeta(.x, "paralelo"))
toc()

# tengo que prevenir que el archivo temporal no se haga siempre en la misma carpeta

crea_reporte_carpeta2 <- function(pais, carpeta){
  
  rmarkdown::render(input = "reporte/reporte_template.Rmd", 
                    params = list(pais = pais),
                    output_dir = paste("reporte/", carpeta),
                    intermediates_dir = paste("reporte/", carpeta), # acá cambio la ruta del archivo intermedio
                    output_file = paste0("/reporte_", janitor::make_clean_names(pais), ".docx"))
}

# sigue siendo no independiente

tic()
furrr::future_map(as.character(unique(datos_paises$country)), ~crea_reporte_carpeta2(.x, "paralelo"))
toc()

# Veamos ahora creando una carpeta para cada reporte

crea_reporte_carpeta3 <- function(pais, carpeta){
  
  rmarkdown::render(input = "reporte/reporte_template.Rmd", 
                    params = list(pais = pais),
                    output_dir = paste0(getwd(), "/reporte/", carpeta, "/", pais),
                    intermediates_dir =paste0(getwd(), "/reporte/", carpeta, "/", pais),
                    output_file = paste0("/reporte_", janitor::make_clean_names(pais), ".docx"))
}

tic()
furrr::future_map(as.character(unique(datos_paises$country)), ~crea_reporte_carpeta3(.x, "paralelo"))
toc()
