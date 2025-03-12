{-|
Copyright        : (c) Galois, Inc. 2024
Maintainer       : GREASE Maintainers <grease@galois.com>
-}

{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Functionality for logging diagnostic messages in @grease@.
module Grease.Diagnostic
  ( Diagnostic(..)
  , GreaseLogAction
  , log
  , severity
  ) where

import Control.Monad.IO.Class (MonadIO (..))
import qualified Data.Time.Clock as Time
import qualified Data.Time.Format as Time
import qualified Lumberjack as LJ
import Prelude hiding (log)
import qualified Prettyprinter as PP
import qualified Prettyprinter.Render.Text as PP
import System.IO (stderr)

import Grease.Diagnostic.Severity (Severity)
import qualified Grease.BranchTracer.Diagnostic as BranchTracer
import qualified Grease.Heuristic.Diagnostic as Heuristic
import qualified Grease.LLVM.Overrides.Diagnostic as LLVMOverrides
import qualified Grease.LLVM.SimulatorHooks.Diagnostic as LLVMSimulatorHooks
import qualified Grease.Macaw.Load.Diagnostic as Load
import qualified Grease.Macaw.ResolveCall.Diagnostic as ResolveCall
import qualified Grease.Macaw.SimulatorHooks.Diagnostic as SimulatorHooks
import qualified Grease.Main.Diagnostic as Main
import qualified Grease.Refine.Diagnostic as Refine
import qualified Grease.Setup.Diagnostic as Setup
import qualified Grease.Skip.Diagnostic as Skip

-- | A diagnostic message that @grease@ can emit.
--
-- Diagnostics for each module are defined in a sub-module. Each diagnostic
-- type implements 'PP.Pretty'.
data Diagnostic where
  BranchTracerDiagnostic :: BranchTracer.Diagnostic -> Diagnostic
  HeuristicDiagnostic :: Heuristic.Diagnostic -> Diagnostic
  LLVMOverridesDiagnostic :: LLVMOverrides.Diagnostic -> Diagnostic
  LLVMSimulatorHooksDiagnostic :: LLVMSimulatorHooks.Diagnostic -> Diagnostic
  LoadDiagnostic :: Load.Diagnostic -> Diagnostic
  MainDiagnostic :: Main.Diagnostic -> Diagnostic
  RefineDiagnostic :: Refine.Diagnostic -> Diagnostic
  ResolveCallDiagnostic :: ResolveCall.Diagnostic -> Diagnostic
  SetupDiagnostic :: Setup.Diagnostic -> Diagnostic
  SimulatorHooksDiagnostic :: SimulatorHooks.Diagnostic -> Diagnostic
  SkipDiagnostic :: Skip.Diagnostic -> Diagnostic

instance PP.Pretty Diagnostic where
  pretty =
    \case
      BranchTracerDiagnostic diag -> PP.pretty diag
      HeuristicDiagnostic diag -> PP.pretty diag
      LLVMOverridesDiagnostic diag -> PP.pretty diag
      LLVMSimulatorHooksDiagnostic diag -> PP.pretty diag
      LoadDiagnostic diag -> PP.pretty diag
      MainDiagnostic diag -> PP.pretty diag
      RefineDiagnostic diag -> PP.pretty diag
      ResolveCallDiagnostic diag -> PP.pretty diag
      SetupDiagnostic diag -> PP.pretty diag
      SimulatorHooksDiagnostic diag -> PP.pretty diag
      SkipDiagnostic diag -> PP.pretty diag

severity :: Diagnostic -> Severity
severity =
  \case
    BranchTracerDiagnostic diag -> BranchTracer.severity diag
    HeuristicDiagnostic diag -> Heuristic.severity diag
    LLVMOverridesDiagnostic diag -> LLVMOverrides.severity diag
    LLVMSimulatorHooksDiagnostic diag -> LLVMSimulatorHooks.severity diag
    LoadDiagnostic diag -> Load.severity diag
    MainDiagnostic diag -> Main.severity diag
    RefineDiagnostic diag -> Refine.severity diag
    ResolveCallDiagnostic diag -> ResolveCall.severity diag
    SetupDiagnostic diag -> Setup.severity diag
    SimulatorHooksDiagnostic diag -> SimulatorHooks.severity diag
    SkipDiagnostic diag -> Skip.severity diag

-- | The type of @grease@ 'LJ.LogAction's. This must work over any 'MonadIO'
-- instance to ensure that we can log messages in multiple monads, including
-- 'IO' and @'StateT' s 'IO'@.
type GreaseLogAction = forall m. MonadIO m => LJ.LogAction m Diagnostic

-- | Log a message to 'stderr' along with the current time.
log :: MonadIO m => PP.Doc a -> m ()
log msg = do
  t <- liftIO Time.getCurrentTime
  let time = Time.formatTime Time.defaultTimeLocale "[%F %T]" t
  liftIO $ PP.hPutDoc stderr $ PP.pretty time PP.<+> msg
  liftIO $ PP.hPutDoc stderr PP.line
