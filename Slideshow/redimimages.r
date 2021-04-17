library("imager")

#load ifmag
original = imager::load.image("images/imagen1.jpg")
d = dim(original)[1:2]
d

#size check
fs::file_info("office.jpeg")$size

scale = max(d / 800)
img = imager::resize(original, 
                     imager::width(original) / scale, 
                     imager::height(original) / scale,
                     interpolation_type = 6)
img

## add square padding  - not needed
square_img = imager::pad(img, 
                         nPix = 400 - height(img), 
                         axes = "y", 
                         val = "white")
 imager::save.image(square_img, file = "images/square_imagen1.jpg")
 
 
 ## save image
 
 imager::save.image(img, file = "images/redim_imagen1.jpg")