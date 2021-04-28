## -------------------------------------------------------------------------------------
## Sistemas Inteligentes para la Gestión en la Empresa
## Curso 2020-2021
## Juan Gómez Romero
## -------------------------------------------------------------------------------------

## -------------------------------------------------------------------------------------
## BIBLIOTECAS
library(tidyverse)

## -------------------------------------------------------------------------------------
## FUNCIONES

# Crear carpetas con imágenes para entrenamiento con Keras
# - tsv_folder: directorio incluyendo los .tsv con los metadatos
# - img_folder: directorio incluyendo las imágenes
# - target: nombre de la columna con el objetivo de predicción (2_way_label)
# - output: directorio donde se guardarán las imágenes extraídas
# - sample_train: tamaño de la muestra aleatoria sobre el conjunto de test (todas las imágenes)
# - sample_val: tamaño de la muestra aleatoria del conjunto de validación (todas las imágenes)
# - sample_test: tamaño de la muestra aleatoria del conjunto de test (todas las imágenes)
make_dataset_from_metadata <- function(tsv_folder, img_folder, target = "2_way_label", output,
                                       sample_train = NULL, sample_val = NULL, sample_test = NULL) {
  
  # crear directorio de salida
  dir.create(output)
  
  # crear parametros para bucle train, val, test
  params <- tibble(
    steps  = c("train", "validation", "test"),
    tsv    = c("/multimodal_train.tsv", "/multimodal_validate.tsv", "/multimodal_test_public.tsv"), 
    folder = c("/train", "/val", "/test"),
    sample = c(sample_train, sample_val, sample_test)
  )
  
  ## procesar cada uno de los tres subconjuntos train, val, test
  for(i in 1:nrow(params)) {
    
    # paso actual
    step <- params$steps[[i]]
    print(paste0("Procesando conjunto ", step, "..."))
    
    # leer datos
    tsv_file <- paste0(tsv_folder, params$tsv[[i]])
    data <- read_tsv(tsv_file)
    
    # crear directorio
    output_folder <- paste0(output, params$folder[[i]])
    dir.create(output_folder)
    
    # crear carpetas por cada clase
    for(class in unique(data[[target]])) {
      new_dir <- paste0(output_folder, "/", class)
      if(!dir.exists(new_dir)) {
        dir.create(new_dir)
      }
    }
    
    # tomar muestra de imágenes
    if(!is.null(params$sample[[i]])) {
      data_sample <- data %>%
        slice_sample(n = params$sample[[i]])
    } else {
      data_sample <- data
    }
    
    # copiar ficheros
    files_to_copy <- tibble(from = paste0(img_folder, "/", data_sample$id, ".jpg"), 
                            to   = paste0(output_folder, "/", data_sample[[target]], "/", data_sample$id, ".jpg"))
    file.copy(files_to_copy$from, files_to_copy$to)
    
    # escribir .tsv
    write_tsv(data_sample, file = paste0(output_folder, params$tsv[[i]]))
  }
}

## -------------------------------------------------------------------------------------
## CREAR PARTICIÓN
make_dataset_from_metadata(tsv_folder = "metadata", 
                           img_folder = "public_image_set", 
                           target     = "6_way_label",
                           output     = "all_sixClasses")
                           # sample_train = 50, sample_val = 10, sample_test = 10)
