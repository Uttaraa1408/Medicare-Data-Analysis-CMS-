############################################
# PACKAGES
############################################
# install.packages(c("readxl","dplyr","rpart","rpart.plot","caret","randomForest"))

library(readxl)
library(dplyr)
library(rpart)
library(rpart.plot)
library(caret)
library(randomForest)

############################################
# 1) READ DATA
############################################
# Set your working directory (change if needed)
setwd("D:/Fall 2025/Project Seminar/PROJECT/")

medicare_raw <- read_excel("Correlation_Table_Final_0811.xlsx")

############################################
# 2) BUILD ANALYSIS DATA: medicare_mdc
############################################
medicare_mdc <- medicare_raw %>%
  select(
    Hospital_Overall_Rating,
    Metro,
    EmergencyCare,
    GovernmentCare,
    AcuteCare,
    Score,
    MDC_4, MDC_5, MDC_8, MDC_18
  ) %>%
  mutate(
    Hospital_Overall_Rating = factor(Hospital_Overall_Rating, ordered = TRUE),
    Metro          = factor(Metro),
    EmergencyCare  = factor(EmergencyCare),
    GovernmentCare = factor(GovernmentCare),
    AcuteCare      = factor(AcuteCare)
    # Score and MDC_4/5/8/18 stay numeric
  )

# Remove missing values
medicare_mdc <- na.omit(medicare_mdc)

############################################
# 3) FUNCTION TO RUN DT + RF FOR A SPLIT
############################################
run_models <- function(data, p_split = 0.8, seed = 123, split_label = "80_20") {
  
  cat("\n=====================================\n")
  cat(" Split proportion (train) =", p_split, "\n")
  cat("=====================================\n\n")
  
  set.seed(seed)
  idx <- createDataPartition(
    data$Hospital_Overall_Rating,
    p = p_split,
    list = FALSE
  )
  
  train_dat <- data[idx, ]
  test_dat  <- data[-idx, ]
  
  cat("Train n =", nrow(train_dat), " | Test n =", nrow(test_dat), "\n\n")
  
  ############################################
  # DECISION TREE
  ############################################
  cat("########## DECISION TREE ##########\n\n")
  
  tree_mdc <- rpart(
    Hospital_Overall_Rating ~ .,
    data   = train_dat,
    method = "class",
    control = rpart.control(cp = 0.005, minbucket = 20)
  )
  
  # Save Decision Tree plot
  tree_png_name <- paste0("Decision_Tree_Score_MDC4_5_8_18_", split_label, ".png")
  png(tree_png_name, width = 1500, height = 1200)
  rpart.plot(
    tree_mdc,
    type = 2,
    extra = 104,
    box.palette = "Blues",
    main = paste("Decision Tree (Score + MDC_4,5,8,18) -", split_label)
  )
  dev.off()
  
  # Confusion matrix on test
  pred_tree <- predict(tree_mdc, newdata = test_dat, type = "class")
  cm_tree   <- confusionMatrix(pred_tree, test_dat$Hospital_Overall_Rating)
  
  cat("Decision Tree - Confusion Matrix (Test):\n")
  print(cm_tree)
  cat("\n")
  
  # Variable importance
  vi_tree <- tree_mdc$variable.importance
  vi_tree_df <- data.frame(
    Variable   = names(vi_tree),
    Importance = as.numeric(vi_tree)
  ) %>%
    arrange(desc(Importance))
  
  cat("Decision Tree - Variable Importance:\n")
  print(vi_tree_df)
  cat("\n")
  
  ############################################
  # RANDOM FOREST
  ############################################
  cat("########## RANDOM FOREST ##########\n\n")
  
  rf_model_mdc <- randomForest(
    Hospital_Overall_Rating ~ .,
    data = train_dat,
    ntree = 500,
    mtry  = 4,
    importance = TRUE
  )
  
  cat("Random Forest - OOB summary:\n\n")
  print(rf_model_mdc)   # includes OOB error + OOB confusion matrix
  cat("\n")
  
  # Confusion matrix on test
  pred_rf <- predict(rf_model_mdc, newdata = test_dat, type = "class")
  cm_rf   <- confusionMatrix(pred_rf, test_dat$Hospital_Overall_Rating)
  
  cat("Random Forest - Confusion Matrix (Test):\n")
  print(cm_rf)
  cat("\n")
  
  # Variable importance + PNG
  rf_imp <- importance(rf_model_mdc)
  
  cat("Random Forest - Variable Importance:\n")
  print(rf_imp)
  cat("\n")
  
  rf_imp_png_name <- paste0("RF_VarImp_Score_MDC4_5_8_18_", split_label, ".png")
  png(rf_imp_png_name, width = 1500, height = 1200)
  varImpPlot(
    rf_model_mdc,
    main = paste("Variable Importance (RF: Score + MDCs) -", split_label)
  )
  dev.off()
  
  ############################################
  # SUMMARY ACCURACY PRINT
  ############################################
  acc_tree <- cm_tree$overall["Accuracy"]
  acc_rf   <- cm_rf$overall["Accuracy"]
  
  cat("Summary Accuracy (Test):\n")
  cat("  Decision Tree Accuracy:", round(acc_tree, 4), "\n")
  cat("  Random Forest Accuracy:", round(acc_rf, 4), "\n\n")
  
  ############################################
  # RETURN OBJECT
  ############################################
  invisible(list(
    split = list(
      p_split = p_split,
      train_n = nrow(train_dat),
      test_n  = nrow(test_dat)
    ),
    tree = list(
      model = tree_mdc,
      confusion = cm_tree,
      varimp = vi_tree_df,
      plot_file = tree_png_name
    ),
    rf = list(
      model = rf_model_mdc,
      confusion = cm_rf,
      importance = rf_imp,
      varimp_plot_file = rf_imp_png_name
    )
  ))
}

############################################
# 4) RUN MODELS FOR 80/20 AND 70/30
############################################

# 80/20 split
results_80_20 <- run_models(
  data        = medicare_mdc,
  p_split     = 0.80,
  seed        = 123,
  split_label = "80_20"
)

# 70/30 split
results_70_30 <- run_models(
  data        = medicare_mdc,
  p_split     = 0.70,
  seed        = 123,
  split_label = "70_30"
)

############################################
# END
############################################
