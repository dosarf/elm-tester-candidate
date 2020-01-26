package io.github.dosarf.tester.testercandidate.user;

import org.springframework.data.repository.CrudRepository;

// see https://spring.io/guides/gs/accessing-data-jpa/
public interface UserService extends CrudRepository<User, Long> {

}
