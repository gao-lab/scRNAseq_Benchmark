directories <- commandArgs(TRUE)
for(directory in directories){
  results=dir(directory)
  for(result in results){
    output_dir=strsplit(directory, "/evaluation")[[1]][1]
    output_dir=strsplit(output_dir, "output/")[[1]][2]
    tool_numb=strsplit(directory, "Summary/")[[1]][2]
    tool=strsplit(tool_numb, "/")[[1]][1]
    feature_numb=strsplit(tool_numb, "/")[[1]][2]
    dataset_name=strsplit(result, ".csv")[[1]][1]
    df=read.csv(file.path(directory, result), row.names = 1, header = TRUE)
    whole_df <- data.frame(Data_type=strsplit(output_dir, "/")[[1]][1],Data=output_dir,Fold=dataset_name,Tool=tool, feature=feature_numb, df)
    if(file.exists("output/result_summary_all.csv")){
      write.table(whole_df, "output/result_summary_all.csv", append = TRUE, row.names = FALSE,sep=",", col.names = FALSE)
    }else{
      write.table(whole_df, "output/result_summary_all.csv", append = TRUE, row.names = FALSE,sep=",")
    }
  }
}