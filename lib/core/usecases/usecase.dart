import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tdd_arch/core/error/Failure.dart';
import 'package:flutter/cupertino.dart';


abstract class UseCase<Type, Params> {
	Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {}