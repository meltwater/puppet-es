class es::instances ($instance) {
  $real_instance = hiera_hash(es::instances::instance)
  create_resources('es', $real_instance)
}
