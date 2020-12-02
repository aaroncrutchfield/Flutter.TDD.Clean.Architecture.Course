import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tdd_arch/core/error/Failure.dart';
import 'package:flutter_tdd_arch/core/usecases/usecase.dart';
import 'package:flutter_tdd_arch/features/number_trivia/domain/contracts/number_trivia_repository.dart';
import 'package:flutter_tdd_arch/features/number_trivia/domain/entities/number_trivia.dart';

class GetRandomNumberTrivia implements UseCase<NumberTrivia, NoParams> {
	final repository;

  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) async {
    return await repository.getRandomNumberTrivia();
  }

}