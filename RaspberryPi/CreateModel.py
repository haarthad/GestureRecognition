import cv2
import numpy as np
import os
from random import shuffle
from tqdm import tqdm
import tensorflow as tf
from tensorflow import keras
import matplotlib.pyplot as plt
#%matplotlib inline

###############################################################################
# Defines
###############################################################################
train_data  = 'ImageData/Train'
test_data   = 'ImageData/Test'
personal_test_data = 'ImageData/PersonalTest'
class_names = ['A','B','C','Five','Point','V']
X_OF_IMAGES = 50
Y_OF_IMAGES = 50
NUMBER_OF_EPOCHS = 100

###############################################################################
# Methods
###############################################################################
def assignHotLabel(image):
	label = image.split('-')[0]
	hot_label = np.array([0,0,0,0,0,0])

	if label == 'A':
		hot_label = np.array([1,0,0,0,0,0])
	elif label == 'B':
		hot_label = np.array([0,1,0,0,0,0])
	elif label == 'C':
		hot_label = np.array([0,0,1,0,0,0])
	elif label == 'Five':
		hot_label = np.array([0,0,0,1,0,0])
	elif label == 'Point':
		hot_label = np.array([0,0,0,0,1,0])
	elif label == 'V':
		hot_label = np.array([0,0,0,0,0,1])
	return hot_label
	
def trainData():
	train_images = []
	for i in tqdm(os.listdir(train_data)):
		path = os.path.join(train_data, i)
		image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
		image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
		train_images.append([np.array(image), assignHotLabel(i)])
	shuffle(train_images)
	return train_images
	
def testData():
	test_images = []
	for i in tqdm(os.listdir(test_data)):
		path = os.path.join(test_data, i)
		image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
		image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
		test_images.append([np.array(image), assignHotLabel(i)])
	shuffle(test_images)
	return test_images
    
def personalTestData():
	personal_test_images = []
	for i in tqdm(os.listdir(personal_test_data)):
		path = os.path.join(personal_test_data, i)
		image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
		image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
		personal_test_images.append([np.array(image), assignHotLabel(i)])
	shuffle(personal_test_images)
	return personal_test_images

def plot_image(i, predictions_array, true_label, img):
  predictions_array, true_label, img = predictions_array[i], true_label[i], img[i]
  plt.grid(False)
  plt.xticks([])
  plt.yticks([])
  img = img[0]
  data = img.reshape(1,X_OF_IMAGES,Y_OF_IMAGES,1)
  model_out = model.predict([data])
  plt.imshow(img, cmap='gray')

  predicted_label = np.argmax(model_out)
  true_label = np.argmax(true_label)
  if predicted_label == true_label:
    color = 'blue'
  else:
    color = 'red'
  
  plt.xlabel("{} {:2.0f}% ({})".format(class_names[predicted_label],
                                100*np.max(predictions_array),
                                class_names[true_label]),
                                color=color)

def plot_value_array(i, predictions_array, true_label):
  predictions_array, true_label = predictions_array[i], true_label[i]
  plt.grid(False)
  plt.xticks([])
  plt.yticks([])
  thisplot = plt.bar(range(6), predictions_array, color="#777777")
  plt.ylim([0, 1]) 
  predicted_label = np.argmax(predictions_array)
 
  thisplot[predicted_label].set_color('red')
  thisplot[np.argmax(true_label)].set_color('blue')
  
###############################################################################
# Main logic
###############################################################################

# Read in images and attach a label to each image
training_image_list = trainData()
testing_image_list = testData()
personal_testing_image_list = personalTestData()

# Reshape images to be passed through the convolution layers
training_images = np.array([i[0] for i in training_image_list]).reshape(-1,X_OF_IMAGES,Y_OF_IMAGES,1)
training_labels     = np.array([i[1] for i in training_image_list])
testing_images = np.array([i[0] for i in testing_image_list]).reshape(-1,X_OF_IMAGES,Y_OF_IMAGES,1)
testing_labels     = np.array([i[1] for i in testing_image_list])
personal_testing_images = np.array([i[0] for i in personal_testing_image_list]).reshape(-1,X_OF_IMAGES,Y_OF_IMAGES,1)
personal_testing_labels     = np.array([i[1] for i in personal_testing_image_list])

# Pass all images through a Sobel filter
#map(lambda x:tf.image.sobel_edges(x), training_images)
#map(lambda x:tf.image.sobel_edges(x), testing_images)
#map(lambda x:tf.image.sobel_edges(x), personal_testing_images)

# Preprocess all images so the values for each images fall between 0 and 1
training_images = training_images / 255.0
testing_images = testing_images / 255.0
personal_testing_images = personal_testing_images / 255.0

# Set parameters and layers for the model
model = keras.Sequential([
	keras.layers.InputLayer(input_shape=[X_OF_IMAGES,Y_OF_IMAGES,1]),
	keras.layers.Conv2D(filters=32, kernel_size=5, strides=1, padding='same', activation='relu'),
	keras.layers.MaxPool2D(pool_size=5, padding='same'),
	keras.layers.Conv2D(filters=50, kernel_size=5, strides=1, padding='same', activation='relu'),
	keras.layers.MaxPool2D(pool_size=5, padding='same'),
	keras.layers.Conv2D(filters=80, kernel_size=5, strides=1, padding='same', activation='relu'),
	keras.layers.MaxPool2D(pool_size=5, padding='same'),
	keras.layers.Dropout(0.25),
	keras.layers.Flatten(),
    keras.layers.Dense(512, activation=tf.nn.relu),
	keras.layers.Dropout(0.5),
	keras.layers.Dense(6, activation=tf.nn.softmax),
])

# Compile model with the following parameters
model.compile(optimizer=tf.train.AdamOptimizer(0.001),
			  loss='categorical_crossentropy',
			  metrics=['accuracy'])

# Create model based on above parameters for the training images
model.fit(training_images,training_labels,epochs=NUMBER_OF_EPOCHS)

# Calculate and print accuracy for training, test, and personal test images
training_loss, training_accuracy = model.evaluate(training_images, training_labels)
testing_loss, testing_accuracy = model.evaluate(testing_images, testing_labels)
personal_loss, personal_accuracy = model.evaluate(personal_testing_images, personal_testing_labels)
print('Training accuracy:', training_accuracy)
print('Testing accuracy:', testing_accuracy)
print('Personal testing accuracy:', personal_accuracy)

# Get category percentages for all test images
predictions = model.predict(testing_images)

# Print the first 25 test images, and their predicted values for each category
# Uncomment plt.show to see the plot
num_rows = 5
num_cols = 5
num_images = num_rows*num_cols
plt.figure(figsize=(2*2*num_cols, 2*num_rows))
for i in range(num_images):
    plt.subplot(num_rows, 2*num_cols, 2*i+1)
    plot_image(i, predictions, testing_labels, testing_image_list)
    plt.subplot(num_rows, 2*num_cols, 2*i+2)
    plot_value_array(i, predictions, testing_labels)
#plt.show()