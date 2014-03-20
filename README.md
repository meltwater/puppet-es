Elastic Search Defined Type
===========================
This defined type provides a way to use multiple Elastic Search instances on a single machine.

Dependencies
------------
An installed version of java, a service user and a parent directory to install to. These dependencies are purposely not supplied to allow easy integration into existing codebases.

How to use:
-----------

    es {'es-instance1':
      version => '1.0.1',
      xms => '128m',
      xmx => '128m',
      javahome => '/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.25.x86_64',
      custom_config => ['node.tag: ssd'],
      clustername => 'elasticsearch',
      nodedata => true,
      master => true,
      spmkey => 'none',
      multicast => true,
      es_unicast_hosts => none,
      threadpools => false
    }

    es {'es-instance2':
      version => '1.0.1',
      xms => '128m',
      xmx => '128m',
      javahome => '/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.25.x86_64',
      custom_config => ['node.tag: disk'],
      clustername => 'elasticsearch',
      nodedata => true,
      master => true,
      spmkey => 'none',
      multicast => true,
      es_unicast_hosts => none,
      threadpools => false
    }
