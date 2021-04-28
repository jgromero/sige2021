import os
from PIL import Image

data_folders         = ['medium10000_twoClasses/train/',
                        'medium10000_twoClasses/val/',
                        'medium10000_twoClasses/test/']
processed_extensions = []
excluded_extensions  = ['tsv']

for folder_path in data_folders:
    for fldr in os.listdir(folder_path):
      sub_folder_path = os.path.join(folder_path, fldr)
      if os.path.isdir(sub_folder_path):
        for filee in os.listdir(sub_folder_path):
          file_path = os.path.join(sub_folder_path, filee)
          print('** Path: {}  **'.format(file_path), end="\r", flush=True)
          
          try:
            file_extension = filee.split('.')[1]
            if file_extension not in excluded_extensions:
              im = Image.open(file_path)
              rgb_im = im.convert('RGB')
              
              if file_extension not in processed_extensions:
                processed_extensions.append(file_extension)
          except:
            print('\n** Error while processing Path: {}... removing file **\n'.format(file_path), end="\r", flush=True)
            os.remove(file_path)
