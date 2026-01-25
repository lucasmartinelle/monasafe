/// Data layer exports
///
/// Ce fichier exporte tous les éléments publics de la couche données
/// pour simplifier les imports dans le reste de l'application.
library;

// Type converters (enums)
export 'local/converters/type_converters.dart';
export 'local/daos/statistics_dao.dart'
    show CategoryStatistics, FinancialSummary, MonthlyStatistics;
// DAOs (pour les cas avancés - préférer les repositories)
export 'local/daos/transaction_dao.dart' show TransactionWithDetails;
// Database
export 'local/database.dart';
// Providers
export 'providers/database_providers.dart';
// Repositories
export 'repositories/account_repository.dart';
export 'repositories/category_repository.dart';
export 'repositories/transaction_repository.dart';
