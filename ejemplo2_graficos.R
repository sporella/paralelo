library(tictoc)
library(tidyverse)

datos_paises <- gapminder::gapminder


# Primero una prueba de concepto ------------------------------------------

datos_paises %>% 
  filter(country == "Chile") %>% 
  ggplot(aes(x = year, y = lifeExp))+
  geom_line(color = "plum")+
  geom_point(color = "plum")+
  facet_wrap(~country)


# Ahora hago la función ---------------------------------------------------

plot_pais <- function(pais){

datos_paises %>% 
  filter(country == pais) %>% 
  ggplot(aes(x = year, y = lifeExp))+
  geom_line(color = "plum")+
  geom_point(color = "plum")+
  geom_smooth()+  
  facet_wrap(~country)
}


# Probar si funciona con otro país ----------------------------------------

plot_pais("Argentina")
plot_pais("Mexico")


algunos_paises <- sample(unique(datos_paises$country), 10)

system.time(map(algunos_paises, ~plot_pais(.x)))


# Ahora para todos los países ---------------------------------------------

system.time(map(unique(datos_paises$country), ~plot_pais(.x)))

library(tictoc)

tic()
map(unique(datos_paises$country), ~plot_pais(.x))
toc() # 23.623 sec elapsed


# Ahora paralelizado ------------------------------------------------------

library(furrr)


plan(strategy = "future::multisession", workers = future::availableCores() - 2)

tic()
furrr::future_map(unique(datos_paises$country), ~plot_pais(.x))
toc() # 24.738 sec elapsed


tic()
furrr::future_map(unique(datos_paises$country), ~plot_pais(.x))
toc() # 24.738 sec elapsed



# Ahora guardando gráficos ------------------------------------------------


plot_pais_guardar <- function(pais){
  
  p1 <- datos_paises %>% 
    filter(country == pais) %>% 
    ggplot(aes(x = year, y = lifeExp))+
    geom_line(color = "plum")+
    geom_point(color = "plum")+
    geom_smooth()+  
    facet_wrap(~country)
  
  ggsave(filename = paste0("graficos/plot_", janitor::make_clean_names(pais), ".png"), plot = p1)
}

plot_pais_guardar("Chile")

plan("multisession", workers = 8)

tic()
furrr::future_map(unique(datos_paises$country), ~plot_pais_guardar(.x))
toc()



# Ahora hago la función pero con una carpeta de destino -------------------

plot_pais_guardar_carpeta <- function(pais, carpeta){
  
  p1 <- datos_paises %>% 
    filter(country == pais) %>% 
    ggplot(aes(x = year, y = lifeExp))+
    geom_line(color = "plum")+
    geom_point(color = "plum")+
    geom_smooth()+  
    facet_wrap(~country)
  
  ggsave(filename = paste0("graficos/",carpeta, "/plot_", janitor::make_clean_names(pais), ".png"), plot = p1)
}

tic()
map(unique(datos_paises$country), ~plot_pais_guardar_carpeta(.x, "no_paralelo"))
toc()


tic()
furrr::future_map(unique(datos_paises$country), ~plot_pais_guardar_carpeta(.x, "paralelo"))
toc()


