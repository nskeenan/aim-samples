<?php
/*===========================================================
Set up residential service content for this theme.
===========================================================*/

namespace InspyreTheme;

function residential_service($param = '') {
  $id = get_the_ID();
  $rs = pods('residential_service', $id);
  if ($rs->exists()) {
      $rs_title = $rs->field('post_title');
      $rs_city = $rs->field('city');

      $county_id = $rs->field('county');
      if (!empty($county_id)) {
          if (!is_array($county_id)) {
              $county_id = array($county_id);
          }

          // Debugging: output raw related_states data
          // echo '<pre>';
          // print_r($county_id);
          // echo '</pre>';

          foreach ($county_id as $county) {
              $county_pod = pods('counties', $county);
              if ($county_pod->exists()) {
                  $rs_county = $county_pod->field('county_name');
              }
          }
      } else {
          echo 'No related counties found.';
      }

      $state_id = $rs->field('state');
      if (!empty($state_id)) {
          if (!is_array($state_id)) {
              $state_id = array($state_id);
          }

          // Debugging: output raw related_states data
          // echo '<pre>';
          // print_r($state_id);
          // echo '</pre>';

          foreach ($state_id as $state) {
              $state_pod = pods('states', $state);
              if ($state_pod->exists()) {
                  $rs_state_long = $state_pod->field('state_long');
                  $rs_state_short = $state_pod->field('state_short');
              }
          }
      } else {
          echo 'No related states found.';
      }

      $rs_map_url                         = get_post_meta($id, 'map_url', true);
      $rs_map_caption                     = get_post_meta($id, 'map_caption', true);

      $rs_promo_banner                    = get_post_meta($id, 'promo_banner', true);
      $rs_promo_banner                    = is_array($rs_promo_banner) ? $rs_promo_banner['guid'] : null;
      if (empty($rs_promo_banner)) {
        $rs_promo_banner = get_template_directory_uri() . '/images/residential-banner-special-offer-default.jpg';
      }

      $rs_free_toter_offer                = get_post_meta($id, 'free_toter_offer', true);
      $rs_free_toter_offer_description    = get_post_meta($id, 'free_toter_offer_description', true);
      if (empty($rs_free_toter_offer_offer_description)) {
        $rs_special_service_offer_description = 'Available to new residential customers only';
      }

      $rs_special_service_offer           = get_post_meta($id, 'special_service_offer', true);
      if (empty($rs_special_service_offer)) {
        $rs_special_service_offer = 'First Month Free';
      }

      $rs_special_service_offer_description = get_post_meta($id, 'special_service_offer_description', true);
      if (empty($rs_special_service_offer_description)) {
        $rs_special_service_offer_description = 'Available to new residential customers only';
      }

      $rs_single_day_trash_service        = get_post_meta($id, 'single_day_trash_service', true);
      $rs_single_day_trash_price          = get_post_meta($id, 'single_day_trash_price', true);
      // Set a default value if the retrieved value is empty
      if (empty($rs_single_day_trash_price)) {
        $rs_single_day_trash_price = 'Call For Price';
      }
      $rs_single_day_trash_pickup_day     = get_post_meta($id, 'single_day_trash_pickup_day', true);
      // Set a default value if the retrieved value is empty
      if (empty($rs_single_day_trash_pickup_day)) {
        $rs_single_day_trash_pickup_day = 'Call For Schedule';
      }

      $rs_two_day_trash_service         = get_post_meta($id, 'two_day_trash_service', true);
      $rs_two_day_trash_price           = get_post_meta($id, 'two_day_trash_price', true);
      // Set a default value if the retrieved value is empty
      if (empty($rs_two_day_trash_price)) {
        $rs_two_day_trash_price = 'Call For Price';
      }
      $rs_two_day_trash_pickup_days     = get_post_meta($id, 'two_day_trash_pickup_days', true);
      // Set a default value if the retrieved value is empty
      if (empty($rs_two_day_trash_pickup_days)) {
        $rs_two_day_trash_pickup_days = 'Call For Schedule';
      }

      $rs_additional_trash_toter          = get_post_meta($id, 'additional_trash_toter', true);
      $rs_additional_trash_toter_price    = get_post_meta($id, 'additional_trash_toter_price', true);
      // Set a default value if the retrieved value is empty
      if (empty($rs_additional_trash_toter_price)) {
        $rs_additional_trash_toter_price = 'Call For Price';
      }

      $rs_recycling_service               = get_post_meta($id, 'recycling_service', true);
      $rs_recycling_price                 = get_post_meta($id, 'recycling_price', true);
      // Set a default value if the retrieved value is empty
      if (empty($rs_recycling_price)) {
        $rs_recycling_price = 'Call For Price';
      }
      $rs_recycling_pickup_days           = get_post_meta($id, 'recycling_pickup_days', true);
      // Set a default value if the retrieved value is empty
      if (empty($rs_recycling_pickup_days)) {
        $rs_recycling_pickup_days = 'Call For Schedule';
      }

      $var_key = 'rs_' . preg_replace('/[-]/', '_', $param);
      if(isset($$var_key)){
        return $$var_key;
      }
      return '';
  }
}
