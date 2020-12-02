import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tdd_arch/core/error/Failure.dart';
import 'package:flutter_tdd_arch/core/usecases/usecase.dart';
import 'package:flutter_tdd_arch/features/number_trivia/domain/contracts/number_trivia_repository.dart';
import 'package:flutter_tdd_arch/features/number_trivia/domain/entities/number_trivia.dart';

class GetConcreteNumberTrivia implements UseCase<NumberTrivia, Params>{
	final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>>call(Params params) async {
  	return await repository.getConcreteNumberTrivia(params.number);
  }
}

class Params extends Equatable {
	final int number;

  Params({@required this.number}) : super([number]);
}