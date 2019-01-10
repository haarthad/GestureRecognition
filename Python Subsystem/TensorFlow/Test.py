import tensorflow as tf
import os
import numpy as np
from matplotlib import pyplot as plt

TRAIN_DATA  = 'ImageData/Train/'
TEST_DATA   = 'ImageData/Test/'

train_image_filenames = [TRAIN_DATA+i for i in os.listdir(TRAIN_DATA)][0:2000]
test_image_filenames = [TEST_DATA+i for i in os.listdir(TEST_DATA)][0:500]

def decode_image(image_file_names, resize_func=None):
    
    images = []
    
    graph = tf.Graph()
    with graph.as_default():
        file_name = tf.placeholder(dtype=tf.string)
        file = tf.read_file(file_name)
        image = tf.image.decode_jpeg(file)
        if resize_func != None:
            image = resize_func(image)
    
    with tf.Session(graph=graph) as session:
        tf.initialize_all_variables().run()   
        for i in range(len(image_file_names)):
            images.append(session.run(image, feed_dict={file_name: image_file_names[i]}))
            if (i+1) % 1000 == 0:
                print('Images processed: ',i+1)
        
        session.close()
    
    return images

train_images = decode_image(train_image_filenames)
test_images = decode_image(test_image_filenames)

labels = [[1,0,0,0,0,0] if 'A' in name else
          [0,1,0,0,0,0] if 'B' in name else
          [0,0,1,0,0,0] if 'C' in name else
          [0,0,0,1,0,0] if 'Five' in name else
          [0,0,0,0,1,0] if 'Point' in name else
          [0,0,0,0,0,1] for name in train_images]

dataset = tf.data.Dataset.from_tensor_slices((train_images, labels))

def _parse_function(filename, label):
    image_string = tf.read_file(filename)
    image_decoded = tf.image.decode_jpeg(image_string, channels=3)
    image = tf.cast(image_decoded, tf.float32)
    return image, label

dataset = dataset.map(_parse_function)
dataset = dataset.batch(2)

# step 4: create iterator and final input tensor
iterator = dataset.make_one_shot_iterator()
images, labels = iterator.get_next()

print(images.shape)
print(labels)