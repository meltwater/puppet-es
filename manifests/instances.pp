# Provide a way to use ENC / Hiera to create resources
class es::instances ($instance, $defaults = undef) {
  $real_instance = hiera_hash(es::instances::instance)

  if $defaults {
    create_resources('es', $real_instance, $defaults)
  } else {
    create_resources('es', $real_instance)
  }
}
