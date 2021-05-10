## -------------------------------------------------------------------------------------
## Sistemas Inteligentes para la Gestión en la Empresa
## Curso 2020-2021
## Juan Gómez Romero
## -------------------------------------------------------------------------------------

library(keras)
library(kerastuneR)
library(tensorflow)
library(reticulate)

## -------------------------------------------------------------------------------------
# Instalar kerastunerR
# > En Linux, previamente: sudo apt-get install libmagick++-dev
# install.packages('kerastuneR')
# py_install("kerastuner")

## -------------------------------------------------------------------------------------
## Cargar y pre-procesar datos

# Cargar MNIST
mnist <- dataset_mnist()

x_train <- mnist$train$x
y_train <- mnist$train$y
x_test  <- mnist$test$x
y_test  <- mnist$test$y

# Redimensionar imagenes
x_train <- array_reshape(x_train, c(nrow(x_train), 28, 28, 1))  # 60.000 matrices 28x28x1
x_test  <- array_reshape(x_test,  c(nrow(x_test),  28, 28, 1))  # 60.000 matrices 28x28x1

# Reescalar valores de imagenes a [0, 255]
x_train <- x_train / 255
x_test  <- x_test  / 255

# Crear 'one-hot' encoding
y_train <- to_categorical(y_train, 10)
y_test  <- to_categorical(y_test,  10)

## -------------------------------------------------------------------------------------
## Crear modelo
build_model <- function(hp) {
  
  # Arquitectura
  model <- keras_model_sequential() %>% 
    layer_conv_2d(filters = 20, kernel_size = c(5, 5), activation = "relu", input_shape = c(28, 28, 1)) %>%
    layer_batch_normalization(epsilon = 0.01) %>%
    layer_max_pooling_2d(pool_size = c(2, 2)) %>%
    layer_flatten() %>%
    layer_dense(units = 100, activation = "sigmoid", kernel_regularizer = regularizer_l2(0.01)) %>%
    # layer_dropout(rate = 0.4) %>%
    layer_dense(units = 10, activation = "softmax")
  
  # Compilar 
  model %>% compile(
    loss = 'categorical_crossentropy',
    optimizer = tf$keras$optimizers$Adam(
      hp$Choice('learning_rate', values=c(1e-2, 1e-3, 1e-4))),
    metrics = c('accuracy')
  )
}

## -------------------------------------------------------------------------------------
## Definir 'tuner'
tuner <- RandomSearch(
  build_model,
  objective = 'val_accuracy',
  max_trials = 5,
  executions_per_trial = 3,
  directory = 'tuner',
  project_name = 'my_first_tuner')

tuner %>% search_summary()

## -------------------------------------------------------------------------------------
## Ajustar modelo
model_tuned <- tuner %>% fit_tuner(x_train, y_train,
                                   epochs = 5, 
                                   validation_data = list(x_test, y_test))
plot_tuner(tuner)

## -------------------------------------------------------------------------------------
## Extraer mejores modelos (x5)
best_5_models <- tuner %>% get_best_models(5)

plot_keras_model(best_5_models[[1]])

## -------------------------------------------------------------------------------------
## Usar optimizadores avanzados
tuner <- Hyperband(
  build_model,
  objective = 'val_accuracy',
  max_epochs = 3,
  directory = 'hyper_band_tuner',
  project_name = 'my_second_tuner'
)

model_tuned <- tuner %>% fit_tuner(x_train, y_train,
                                   epochs = 5, 
                                   validation_data = list(x_test, y_test))

plot_tuner(tuner)