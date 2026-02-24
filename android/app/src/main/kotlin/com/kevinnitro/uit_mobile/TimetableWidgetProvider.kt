package com.kevinnitro.uit_mobile

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class TimetableWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.timetable_widget)

            val coursesJson = widgetData.getString("today_courses", "[]") ?: "[]"
            val lastUpdated = widgetData.getString("last_updated", "") ?: ""

            val courseIds = intArrayOf(
                R.id.text_course_1,
                R.id.text_course_2,
                R.id.text_course_3,
                R.id.text_course_4,
                R.id.text_course_5
            )

            // Hide all course slots first.
            courseIds.forEach { id ->
                views.setViewVisibility(id, View.GONE)
            }
            views.setViewVisibility(R.id.text_empty, View.GONE)

            try {
                val courses = JSONArray(coursesJson)
                if (courses.length() == 0) {
                    views.setViewVisibility(R.id.text_empty, View.VISIBLE)
                } else {
                    val count = minOf(courses.length(), courseIds.size)
                    for (i in 0 until count) {
                        val course = courses.getJSONObject(i)
                        val classCode = course.optString("classCode", "")
                        val room = course.optString("room", "")
                        val periods = course.optString("periods", "")
                        val text = "P$periods  $classCode  ($room)"
                        views.setTextViewText(courseIds[i], text)
                        views.setViewVisibility(courseIds[i], View.VISIBLE)
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
