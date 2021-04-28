# About Us
We are a young company passionate about making your videos cool and exciting!
There are many more great effects in our apps(iOS, Android) and in our videos, check them out!
[![VOCHI YOUTUBE](https://img.youtube.com/vi/wcS0o2cxK4w/0.jpg)](http://www.youtube.com/watch?v=wcS0o2cxK4w)
https://vochi.ai/ https://vochi.app/
With us you can learn the magick behind and help us create the future!

# Общие требования

## Задачи

- В папке tasks лежат подпапки с задачами - некоторые из наших эффектов. В каждой находятся:
    - Файл `taks.md` с условием задачи
    - Видеофайл с примером готового эффекта
- В папке effect_sandbox лежит заготовка проекта на `CMake`, которая уже включает в себя сборку `OpenCV` и пример того, как можно замерять скорость работы
- Необязательно делать все или в определенном порядке. Чем больше (и качественнее), тем лучше

## Требования

- Видео с результатом работы программы
- Исходный код (желательно с комментариями в неочевидных местах)
- Краткое описание подхода к решению
- Инструкция по сборке (Os, compiler, commands)
- Замеры скорости на вашем устройстве (время на 1 кадр) и модель процессора

## Критерии оценивания

- Поставленная задача решена
- Выглядит интересно/красиво, креативность
- Код компилируется
- Работает быстро (<45ms/frame avg on desktop/notebook on full hd frame)
- Code style (readability, structure, meaningful names, no >100 lines long loops / functions)
- Возможность легко менять параметры эффекта

## Советы

- [Документация OpenCV](https://docs.opencv.org/4.5.2/)
- Советую пройтись краем глаза по всему модулю [imgproc](https://docs.opencv.org/4.5.2/d7/dbd/group__imgproc.html). Зачастую колесо изобретается только потому, что программист никогда не видел, что данный функционал уже реализован и как это называется
- Большинство арифметических операций с матрицами в `OpenCV` оптимизированы лучше, чем вы напишете руками в цикле
- Полезные функции в `OpenCV`, которые могут пригодиться и облегчить жизнь
  - `remap`
  - `moments`
  - `boundingRect`
  - `split`, `merge`, `mixChannels`
- Если вам безразлично, под какую ОС писать, выбирайте `linux` или `wsl`, так будет проще и приятнее тестировать
