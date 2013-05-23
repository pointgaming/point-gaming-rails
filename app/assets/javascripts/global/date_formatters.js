var PointGaming = PointGaming || {};

PointGaming.formatDate = function(date) {
  return moment(date).zone(PointGaming.timezone_offset || '-06:00').format('MM/DD/YYYY');
};

PointGaming.formatDateTime = function(date_time) {
  return moment(date_time).zone(PointGaming.timezone_offset || '-06:00').format('MM/DD/YYYY h:mm a');
};
