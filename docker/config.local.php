<?php
// Docker: keep the data folder on the /data volume, outside the web root.
define('DPS_DATA', getenv('DPS_DATA') ?: '/data');
