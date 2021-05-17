## -------------------------------------------------------------------------------------
## Sistemas Inteligentes para la Gestión en la Empresa
## Curso 2020-2021
## Juan Gómez Romero
## -------------------------------------------------------------------------------------

library(keras)

## -------------------------------------------------------------------------------------
## Cargar y pre-procesar imágenes
train_dir      <- './cats_and_dogs_small/train/'
validation_dir <- './cats_and_dogs_small/validation/' 
test_dir       <- './cats_and_dogs_small/test/'

train_datagen      <- image_data_generator(rescale = 1/255) 
validation_datagen <- image_data_generator(rescale = 1/255)
test_datagen       <- image_data_generator(rescale = 1/255)

train_data <- flow_images_from_directory(
  directory = train_dir,
  generator = train_datagen,
  target_size = c(150, 150),   # (w, h) --> (150, 150)
  batch_size = 20,             # grupos de 20 imágenes
  class_mode = "binary"        # etiquetas binarias
)

validation_data <- flow_images_from_directory(
  directory = validation_dir,
  generator = validation_datagen,
  target_size = c(150, 150),   # (w, h) --> (150, 150)
  batch_size = 20,             # grupos de 20 imágenes
  class_mode = "binary"        # etiquetas binarias
)

test_data <- flow_images_from_directory(
  directory = test_dir,
  generator = test_datagen,
  target_size = c(150, 150),   # (w, h) --> (150, 150)
  batch_size = 20,             # grupos de 20 imágenes
  class_mode = "binary"        # etiquetas binarias
)

## -------------------------------------------------------------------------------------
## Cargar secciones del ensemble

# Cargar capa convolutiva de VGG16, pre-entrenada con ImageNet
# https://keras.rstudio.com/reference/application_vgg.html
vgg16_base <- application_vgg16(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(150, 150, 3)
)

# Cargar capa convolutiva de MobileNet, pre-entrenada con ImageNet
# https://keras.io/api/applications/mobilenet/
mobile_base <- application_mobilenet_v2(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(150, 150, 3)
)

# Congelar las capas convolutivas ya entrenada
# https://keras.rstudio.com/reference/freeze_weights.html
freeze_weights(vgg16_base)
freeze_weights(mobile_base)

## -------------------------------------------------------------------------------------
## Crear modelo ensemble
model_input  <- layer_input(shape=c(150, 150, 3))

model_list   <- c(vgg16_base(model_input) %>% layer_flatten(), 
                  mobile_base(model_input) %>% layer_flatten())

model_output <- layer_concatenate(model_list) %>%
  layer_dense(units = 512, activation = "relu") %>%
  layer_dense(units = 256, activation = "relu") %>%
  layer_dense(units = 1, activation = "sigmoid")

model <- keras_model(
  inputs  = model_input, 
  outputs = model_output
)

## -------------------------------------------------------------------------------------
## Entrenar modelo (end-to-end)
model %>% compile(
  optimizer = optimizer_rmsprop(lr = 2e-5),
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)

history <- model %>% 
  fit_generator(
    train_data,
    steps_per_epoch = 100,
    epochs = 2, # 30,
    validation_data = validation_data,
    validation_steps = 50
  )

plot(history)

model %>% evaluate_generator(test_data, steps = 50)
