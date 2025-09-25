<?php
/*===========================================================
Set up residential service content for this theme.
===========================================================*/

namespace InspyreTheme;

function residential_areas($param = '') {
  $rs_unique_nc_county_names = [];
  $rs_unique_sc_county_names = [];
  $rs_cities = [];

  $params = [
    'limit' => -1 // Return all rows
  ];

  $rs = pods('residential_service', $params)->data();

  if (!empty($rs)) {
    foreach ($rs as $this_rs) {
      $rsa = pods('residential_service', $this_rs->ID);
      $rs_city = $rsa->field('city');
      $county_id = $rsa->field('county');
      $state_id = $rsa->field('state');

      $rs_county = get_county_name($county_id);
      $state_data = get_state_data($state_id);

      $rs_state_short = $state_data['state_short'];
      $rs_state_long = $state_data['state_long'];

      if ($rs_state_short === "NC" && !in_array($rs_county, $rs_unique_nc_county_names)) {
        $rs_unique_nc_county_names[] = $rs_county;
      } elseif ($rs_state_short === "SC" && !in_array($rs_county, $rs_unique_sc_county_names)) {
        $rs_unique_sc_county_names[] = $rs_county;
      }

      $rs_cities[] = [
        'name' => $rs_city,
        'url' => str_replace(' ', '-', strtolower($rs_city)),
        'county' => $rs_county,
        'state_short' => $rs_state_short,
        'state_long' => $rs_state_long
      ];
    }

    sort($rs_unique_nc_county_names);
    sort($rs_unique_sc_county_names);

    // Debugging: output raw related_states data
    // echo '<pre>';
    // print_r($rs_unique_nc_county_names);
    // print_r($rs_unique_sc_county_names);
    // print_r($rs_cities);
    // echo '</pre>';

    $var_key = 'rs_' . preg_replace('/[-]/', '_', $param);
    if(isset($$var_key)){
      return $$var_key;
    }
  }

  return '';
}

function get_county_name($county_id) {
  if (!empty($county_id)) {
    if (!is_array($county_id)) {
      $county_id = [$county_id];
    }
    foreach ($county_id as $county) {
      $county_pod = pods('counties', $county);
      if ($county_pod->exists()) {
        return $county_pod->field('county_name');
      }
    }
  }
  return null;
}

function get_state_data($state_id) {
  $state_data = [
    'state_short' => '',
    'state_long' => ''
  ];

  if (!empty($state_id)) {
    if (!is_array($state_id)) {
      $state_id = [$state_id];
    }
    foreach ($state_id as $state) {
      $state_pod = pods('states', $state);
      if ($state_pod->exists()) {
        $state_data['state_short'] = $state_pod->field('state_short');
        $state_data['state_long'] = $state_pod->field('state_long');
      }
    }
  }

  return $state_data;
}
?>
