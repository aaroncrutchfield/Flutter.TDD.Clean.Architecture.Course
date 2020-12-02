
import 'package:dartz/dartz.dart';
import 'package:flutter_tdd_arch/core/error/Failure.dart';

import '../entities/number_trivia.dart';

abstract class NumberTriviaRepository {
	Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
	Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}