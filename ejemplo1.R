ruta_archivo <- "data/linkedin_job_postings.csv"

# Explorar diferentes funciones para hacer lo mismo -----------------------


system.time(read.csv(ruta_archivo)) # 11.125 s
system.time(readr::read_csv(ruta_archivo)) # 3.8 s
system.time(data.table::fread(ruta_archivo)) # 2.19 s


microbenchmark::microbenchmark(
  read.csv(ruta_archivo),
  readr::read_csv(ruta_archivo),
  data.table::fread(ruta_archivo), times = 5
)

datos_linkedin <- data.table::fread(ruta_archivo)


# Cómo hacer funciones: repaso --------------------------------------------


library(tidyverse)

# Siempre hacer que funcione para un ejemplo mínimo

datos_linkedin %>% 
 group_by(search_country) %>% 
  summarise(n = n())


# Esta forma no funciona cuando la quiero usar más abajo

cuenta_columna <- function(columna){

  datos_linkedin %>% 
  group_by(columna) %>% 
  summarise(n = n())
}

# tengo que usar el operador {{}} para acceder a las columnas del set de datos

cuenta_columna <- function(columna){
  
  datos_linkedin %>% 
    group_by({{columna}}) %>% 
    summarise(n = n())
}


# Probar si es que funciona como función

cuenta_columna(job_type)


# Hay otra forma que es nombrar las columnas con ""

cuenta_columna2 <- function(columna){
  
  datos_linkedin %>% 
    group_by_at(columna) %>% 
    summarise(n = n())
}

cuenta_columna2("job_type")


# Veamos cuanto se demora de diferentes formas ----------------------------

n_por_columna_lento <- function(columna){
  datos_linkedin <- data.table::fread(ruta_archivo) %>% 
    group_by_at(columna) %>% 
    summarise(n = n())
}


n_por_columna_rapido <- function(columna){
  datos_linkedin %>% 
    group_by_at(columna) %>% 
    summarise(n = n())
}

system.time(n_por_columna_lento("job_type")) # 2.983 s
system.time(n_por_columna_rapido("job_type")) # 0.020 s


# Usando funciones map ----------------------------------------------------

columnas <- c("job_type", "search_country", "search_city", "job_level")

system.time(map(columnas, ~n_por_columna_lento(.x)))
system.time(map(columnas, function(x){n_por_columna_lento(x)}))

system.time(map(columnas, ~n_por_columna_rapido(.x)))
system.time(map(columnas, function(x){n_por_columna_rapido(x)}))


# Hacerlo en paralelo -----------------------------------------------------
library(furrr)

plan("multisession", workers = future::availableCores() - 2)

system.time(furrr::future_map(columnas, ~n_por_columna_lento(.x)))
system.time(furrr::future_map(columnas, ~n_por_columna_lento(.x)))

# Cuando un proceso ya es rápido, puede que em paralelo salga más lento
# por el setup que se hace por detrás

system.time(furrr::future_map(columnas, ~n_por_columna_rapido(.x)))
system.time(furrr::future_map(columnas, ~n_por_columna_rapido(.x)))
