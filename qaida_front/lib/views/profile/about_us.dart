import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О нас'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: [
          Image.asset('assets/logo1.png'),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Добро пожаловать в Qaida - вашего персонального гида по миру интересных мест!',
              softWrap: true,
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Qaida - это уникальное приложение, разработанное с использованием передовых алгоритмов машинного обучения. Наша цель - помочь вам открывать новые места исходя из ваших интересов и истории посещений.',
              softWrap: true,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Мы верим, что каждый человек уникален, и поэтому мы стремимся предоставить вам индивидуальные рекомендации, которые действительно соответствуют вашим предпочтениям. Наша система обучается на основе ваших предыдущих посещений и интересов, чтобы предложить вам места, которые вам действительно понравятся.',
              softWrap: true,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Наша команда состоит из опытных специалистов в области машинного обучения, которые постоянно работают над улучшением наших алгоритмов и предоставлением вам лучших рекомендаций.',
              softWrap: true,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Мы в Qaida рады помочь вам открывать для себя новые места и делиться незабываемыми впечатлениями. Присоединяйтесь к нам и начните свое путешествие прямо сейчас!',
              softWrap: true,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
