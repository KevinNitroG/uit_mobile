package com.kevinnitro.uit_mobile

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class DeadlinesWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.deadlines_widget)

            val deadlinesJson = widgetData.getString("upcoming_deadlines", "[]") ?: "[]"
            val lastUpdated = widgetData.getString("last_updated", "") ?: ""

            val deadlineIds = intArrayOf(
                R.id.text_deadline_1,
                R.id.text_deadline_2,
                R.id.text_deadline_3
            )

            // Hide all deadline slots first.
            deadlineIds.forEach { id ->
                views.setViewVisibility(id, View.GONE)
            }
            views.setViewVisibility(R.id.text_empty, View.GONE)

            try {
                val deadlines = JSONArray(deadlinesJson)
                if (deadlines.length() == 0) {
                    views.setViewVisibility(R.id.text_empty, View.VISIBLE)
                } else {
                    val count = minOf(deadlines.length(), deadlineIds.size)
                    for (i in 0 until count) {
                        val deadline = deadlines.getJSONObject(i)
                        val name = deadline.optString("name", "")
                        val niceDate = deadline.optString("niceDate", "")
                        val text = "$name\n$niceDate"
                        views.setTextViewText(deadlineIds[i], text)
                        views.setViewVisibility(deadlineIds[i], View.VISIBLE)
                    }
                }
            } catch (e: Exception) {
                views.setViewVisibility(R.id.text_empty, View.VISIBLE)
                views.setTextViewText(R.id.text_empty, "Error loading data")
            }

            // Show last updated time.
            if (lastUpdated.isNotEmpty()) {
                val timePart = lastUpdated.substringAfter("T").take(5)
                views.setTextViewText(R.id.text_updated, "Updated $timePart")
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
