import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tdd_arch/core/error/Failure.dart';
import 'package:flutter_tdd_arch/core/error/exceptions.dart';
import 'package:flutter_tdd_arch/core/platform/network_info.dart';
import 'package:flutter_tdd_arch/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_tdd_arch/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_tdd_arch/features/number_trivia/domain/contracts/number_trivia_repository.dart';
import 'package:flutter_tdd_arch/features/number_trivia/domain/entities/number_trivia.dart';

typedef Future<NumberTrivia> _ConcreateOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    @required this.remoteDataSource,
    @required this.localDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return await _getTrivia(
        () => remoteDataSource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() => remoteDataSource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
      _ConcreateOrRandomChooser getConcreteOrRandom) async {
    if (await networkInfo.isConnected) {
      try {
        var remoteTrivia = await getConcreteOrRandom();
        localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
