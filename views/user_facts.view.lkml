view: user_facts {
  derived_table: {
    sql: SELECT users.id AS user_id
          ,COUNT(distinct order_items.order_id) AS lifetime_order_count
          ,SUM(order_items.sale_price) AS lifetime_revenue
          ,MIN(order_items.returned_at) AS first_return_order_date
          ,MAX(order_items.returned_at) AS latest_return_order_date
      FROM public.order_items
          LEFT JOIN public.orders AS orders ON order_items.order_id = orders.id
          LEFT JOIN public.users AS users ON orders.user_id = users.id
      WHERE {% condition select_date %} order_items.returned_at {% endcondition %}
      GROUP BY users.id
       ;;
  }

  filter: select_date {
    type: date
    suggest_explore: order_items
    suggest_dimension: order_items.returned_date
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: lifetime_order_count {
    type: number
    sql: ${TABLE}.lifetime_order_count ;;
  }

  dimension: lifetime_revenue {
    type: number
    sql: ${TABLE}.lifetime_revenue ;;
  }

  dimension_group: first_return_order_date {
    type: time
    sql: ${TABLE}.first_return_order_date ;;
  }

  dimension_group: latest_return_order_date {
    type: time
    sql: ${TABLE}.latest_return_order_date ;;
  }

  measure: average_lifetime_revenue {
    type: average
    sql: ${TABLE}.lifetime_revenue ;;
  }
  measure: average_lifetime_order_count {
    type: average
    sql: ${TABLE}.lifetime_order_count ;;
  }

  set: detail {
    fields: [user_id, lifetime_order_count, lifetime_revenue, first_return_order_date_time, latest_return_order_date_time]
  }
}
