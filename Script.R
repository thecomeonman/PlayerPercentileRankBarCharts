# Put the file path to your dataset here.
# If it's an Excel file, save it as a CSV and put the path to the CSV
# Note the direction of the slashes
# cDataFilePath = 'C:/Downloads/Data.csvs'
cDataFilePath = ''

# Whatever non-metric data you have in your file, which is probably other 
# information about the player, add those column names here
vcIDColumns = c('PlayerName','Age','Team','Season')

# Paste the below lines into your console

library(data.table)
library(ggplot2)
library(scales)

dtStats = fread(cDataFilePath)

dtStatsMelted = melt(
   dtStats,
   id.vars = intersect(
      vcIDColumns,
      colnames(dtStats)
   )
)

dtStatsMelted[,
   variableIndex := .GRP,
   variable
]

dtStatsMelted[,
   Value_pile := rank(value)/ .N,
   variable
]

plotVanillaDesign = ggplot() + 
   geom_rect(
      data = dtStatsMelted[
         PlayerName == cPlayerNameToAnalyse
      ],
      aes(
         xmin = 0,
         ymin = variableIndex - nColumnWidthByTwo,
         xmax = Value_pile, 
         ymax = variableIndex + nColumnWidthByTwo,
         group = paste(PlayerName, variable)
      )
   ) +
   geom_text(
      data = dtStatsMelted[
         PlayerName == cPlayerNameToAnalyse
      ],
      aes(
         x = Value_pile + nBufferForTextHorizontal, 
         y = variableIndex,
         group = paste(PlayerName, variable),
         label = round(value, 2)
      ),
      hjust = 0
   ) +
   scale_y_continuous(
      breaks = dtStatsMelted[, sort(unique(variableIndex))],
      labels = dtStatsMelted[, list(variable = variable[1]), variableIndex][order(variableIndex), variable]
   ) +
   labs(
      title = 'Original Design',
      x = NULL,
      y = NULL
   ) + 
   theme(
      axis.text.x = element_blank()
   )

print(plotVanillaDesign)
