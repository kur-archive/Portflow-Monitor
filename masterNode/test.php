<?php
/**
 * Created by PhpStorm.
 * User: kurisu
 * Date: 2017/09/01
 * Time: 14:21
 */

# get a integer
fscanf(STDIN, "%d", $a);
# get two integers separated with half-width break
fscanf(STDIN, "%d %d", $b, $c);
# get a string
fscanf(STDIN, "%s", $s);
# output
echo ($a+$b+$c)." ".$s."\n";